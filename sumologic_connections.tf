# sumologic_connection docs: https://registry.terraform.io/providers/SumoLogic/sumologic/latest/docs/resources/connection

# Read the Tines webhook URL from TF_VAR_tines_webhook_url.
variable "tines_webhook_url" {
  type        = string
  description = "Tines webhook URL to send Sumo Logic alerts to."
  sensitive   = true
}

# Sumo Logic webhook connection to send alerts to Tines.
resource "sumologic_connection" "tines_webhook" {
  type           = "WebhookConnection"
  name           = "DAC POC - Tines Alert Intake"
  description    = "Sends DAC POC Sumo Monitor alerts to the Tines alert-intake webhook."
  url            = var.tines_webhook_url
  custom_headers = { "Content-Type" : "application/json" }
  # The default payload (JSON string) from Sumo Logic to send to Tines webhook.
  default_payload = <<JSON
{
  "monitor_name": "{{Name}}",
  "monitor_description": "{{Description}}",
  "query_url": "{{QueryURL}}",
  "query": "{{Query}}",
  "trigger_time_range": "{{TriggerTimeRange}}",
  "trigger_time": "{{TriggerTime}}",
  "results": "{{ResultsJson}}"
}
JSON
  webhook_type    = "Webhook"
}
