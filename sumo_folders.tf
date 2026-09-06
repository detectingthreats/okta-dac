# sumologic_monitor_folder docs: https://registry.terraform.io/providers/SumoLogic/sumologic/latest/docs/resources/monitor_folder

# Sumo Logic "Monitors" folder for detection rules.
resource "sumologic_monitor_folder" "detections" {
  name        = "DAC POC Detections"
  description = "Terraform-managed Sumo Monitors for the Detection-as-Code POC."
}
