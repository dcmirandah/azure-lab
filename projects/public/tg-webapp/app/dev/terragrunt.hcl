include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
	source = "../../../../modules/webapp"
}

inputs = {
  location = "italynorth"
}
