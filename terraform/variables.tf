variable "app_name" {
  type        = string
  description = "Application Name"
  default     = "mage-nz-traffic"
}

variable "container_cpu" {
  description = "Container cpu"
  default     = "2"
}

variable "container_memory" {
  description = "Container memory"
  default     = "4Gi"
}

variable "project_id" {
  type        = string
  description = "The name of the project"
  default     = "nz-traffic-dezc2024"
}

# variable "region" {
#   type        = string
#   description = "The default compute region"
#   default     = "us-west2"
# }

# variable "zone" {
#   type        = string
#   description = "The default compute zone"
#   default     = "us-west2-a"
# }

variable "repository" {
  type        = string
  description = "The name of the Artifact Registry repository to be created"
  default     = "mage-data-prep"
}

# variable "docker_image" {
#   type        = string
#   description = "The docker image to deploy to Cloud Run."
#   default     = "mageai/mageai:latest"
# }


variable "credentials" {
  description = "credentials file path"
  type        = string
  default     = "../keys/creds.json"
}

locals {
  envs = { for tuple in regexall("(.*)=(.*)", file("${path.module}/../.env")) : tuple[0] => trimspace(tuple[1]) }
}
