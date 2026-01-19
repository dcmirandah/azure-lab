#!/bin/bash

# Requirements:
## Environment variables set:
##   FOUNDATION_NAME
##   MANAGEMENT_GROUP_NAME
##   PARENT_MANAGEMENT_GROUP_NAME
##   BILLING_SCOPE_ID
##   LOCATION
## Azure CLI installed and logged in
##   az login --service-principal --username "<CLIENT_ID>" --password "<CLIENT_SECRET>" --tenant "<TENANT_ID>"

# Azure Lab Foundation Creation Script
set -e

# Color codes for output
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration
source ../secrets/LAB_FOUNDATION.env

# Derived values
RESOURCE_GROUP_NAME="rg-${FOUNDATION_NAME}-tfstate"
STORAGE_ACCOUNT_NAME="st${FOUNDATION_NAME//-/}"

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}Azure Lab Foundation Setup${NC}"
echo -e "${BLUE}================================${NC}"
echo ""

# Management Group Setup
echo -e "${YELLOW}[1/8] Setting up Management Group...${NC}"
echo "Name: $MANAGEMENT_GROUP_NAME"
echo "Parent: $PARENT_MANAGEMENT_GROUP_NAME"

if ! az account management-group show --name "$MANAGEMENT_GROUP_NAME" &>/dev/null; then
    echo "Creating management group..."
    az account management-group create \
        --name "$MANAGEMENT_GROUP_NAME" \
        --display-name "Lab Management Group" \
        --parent "$PARENT_MANAGEMENT_GROUP_NAME"
    echo -e "${GREEN}✓ Management group created${NC}"
else
    echo -e "${GREEN}✓ Management group already exists${NC}"
fi
echo ""

# Subscription Discovery or Creation
echo -e "${YELLOW}[2/8] Discovering or creating subscription...${NC}"
echo "Name: $FOUNDATION_NAME"

EXISTING_SUB=$(az account list --query "[?displayName=='$FOUNDATION_NAME'].id" -o tsv)

if [ -n "$EXISTING_SUB" ]; then
    SUBSCRIPTION_ID="$EXISTING_SUB"
    echo -e "${GREEN}✓ Subscription found: $SUBSCRIPTION_ID${NC}"
else
    echo "Subscription not found. Creating new subscription ..."


    echo "Creating subscription via alias..."
    ALIAS_RESULT=$(az account alias create \
        --name "${FOUNDATION_NAME}-alias" \
        --display-name "$FOUNDATION_NAME" \
        --billing-scope "$BILLING_SCOPE_ID" \
        --workload "Production" \
        -o json)

    SUBSCRIPTION_ID=$(echo "$ALIAS_RESULT" | jq -r '.properties.subscriptionId')
    echo -e "${GREEN}✓ Subscription created: $SUBSCRIPTION_ID${NC}"
fi
echo ""

# Wait for subscription propagation
echo -e "${YELLOW}[3/8] Waiting for subscription to propagate...${NC}"
sleep 10
echo "Refreshing account list..."
az account list --refresh
echo -e "${GREEN}✓ Subscription ready${NC}"
echo ""

# Set active subscription
echo -e "${YELLOW}[4/8] Activating subscription...${NC}"
echo "Subscription ID: $SUBSCRIPTION_ID"

# List available subscriptions for debugging
echo "Available subscriptions:"
az account list --query "[].{id:id, name:name, isDefault:isDefault}" -o table

# Try to set the subscription
if az account set --subscription "$SUBSCRIPTION_ID" 2>/dev/null; then
    echo -e "${GREEN}✓ Subscription activated${NC}"
else
    echo -e "${YELLOW}Warning: Subscription might not be fully ready. Retrying...${NC}"
    sleep 30
    az account set --subscription "$SUBSCRIPTION_ID"
    echo -e "${GREEN}✓ Subscription activated (after retry)${NC}"
fi
echo ""

# Move to management group
echo -e "${YELLOW}[5/8] Moving subscription to management group...${NC}"
echo "Management Group: $MANAGEMENT_GROUP_NAME"
az account management-group subscription add \
    --name "$MANAGEMENT_GROUP_NAME" \
    --subscription "$SUBSCRIPTION_ID"
echo -e "${GREEN}✓ Subscription moved to management group${NC}"
echo ""

# Create resource group
echo -e "${YELLOW}[6/8] Creating resource group...${NC}"
echo "Name: $RESOURCE_GROUP_NAME"
echo "Location: $LOCATION"
az group create --name "$RESOURCE_GROUP_NAME" --location "$LOCATION"
echo -e "${GREEN}✓ Resource group created${NC}"
echo ""

# Register Storage provider
echo -e "${YELLOW}[6b/8] Registering Storage provider...${NC}"
echo "Registering: Microsoft.Storage"
az provider register --namespace Microsoft.Storage --wait
echo -e "${GREEN}✓ Storage provider registered${NC}"
echo ""

# Create storage account
echo -e "${YELLOW}[7/8] Creating storage account for Terraform state...${NC}"
echo "Name: $STORAGE_ACCOUNT_NAME"
echo "Location: $LOCATION"
echo "SKU: Standard_LRS"
az storage account create \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --name "$STORAGE_ACCOUNT_NAME" \
    --location "$LOCATION" \
    --sku Standard_LRS \
    --allow-shared-key-access false
echo "Creating blob container..."
az storage container create \
    --account-name "$STORAGE_ACCOUNT_NAME" \
    --name tfstate \
    --auth-mode login
echo -e "${GREEN}✓ Storage account and container created${NC}"
echo ""

# Set permissions
echo -e "${YELLOW}[8/8] Configuring permissions...${NC}"
echo "Retrieving current user..."
CURRENT_USER=$(az account show --query user.name -o tsv)
echo "Current User: $CURRENT_USER"

echo "Retrieving service principal ID..."
CURRENT_SP_ID=$(az ad sp show --id "$CURRENT_USER" --query id -o tsv 2>/dev/null || \
    az ad signed-in-user show --query id -o tsv)
echo "Service Principal ID: $CURRENT_SP_ID"

echo "Getting storage account scope..."
SCOPE=$(az storage account show --name "$STORAGE_ACCOUNT_NAME" -g "$RESOURCE_GROUP_NAME" --query id -o tsv)

echo "Assigning Storage Blob Data Contributor role..."
az role assignment create \
    --assignee "$CURRENT_SP_ID" \
    --role "Storage Blob Data Contributor" \
    --scope "$SCOPE"
echo -e "${GREEN}✓ Role assignment completed${NC}"
echo ""

echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}Foundation Setup Complete!${NC}"
echo -e "${GREEN}================================${NC}"
echo ""
echo "Subscription ID: $SUBSCRIPTION_ID"
echo "Resource Group: $RESOURCE_GROUP_NAME"
echo "Storage Account: $STORAGE_ACCOUNT_NAME"
echo "Container: tfstate"
echo ""
