terraform {
  required_providers {
    # Sumo Logic Provider docs: https://registry.terraform.io/providers/SumoLogic/sumologic/latest/docs
    sumologic = {
      source  = "sumoLogic/sumologic"
      version = "2.24.0"
    }
  }
  # Required Terraform version.
  required_version = ">= 1.5.2"
}

# Set these only through TF_VAR_* environment variables in the active PowerShell session.
variable "sumologic_access_id" {
  type        = string
  description = "Sumo Logic Access ID"
  sensitive   = true
}

variable "sumologic_access_key" {
  type        = string
  description = "Sumo Logic Access Key"
  sensitive   = true
}

variable "sumologic_environment" {
  type        = string
  description = "Sumo Logic deployment code derived from the browser hostname"
  default     = "eu"
}

# Configure the Sumo Logic Provider
provider "sumologic" {
  access_id   = var.sumologic_access_id
  access_key  = var.sumologic_access_key
  environment = var.sumologic_environment
}
