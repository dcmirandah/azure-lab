variable "zip_package_url" {
  description = "The public URL to the ZIP package containing your static HTML or Node.js app."
  type        = string
  default     = "https://github.com/Azure-Samples/html-docs-hello-world/releases/download/v1.0.0/html-docs-hello-world.zip"
}
variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "westeurope"
}
