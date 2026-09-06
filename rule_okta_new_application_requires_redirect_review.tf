module "rule_okta_new_application_requires_redirect_review" {
  source                 = "./modules/sumo_monitor"
  standard_name          = "DAC - New Okta OAuth Application Requires Redirect Review"
  standard_description   = "PB-200 [Medium]: Detects successful OAuth client creation. Tines validates the current application configuration, identifies unapproved redirect URIs, and raises severity only when additional risk signals are present."
  standard_query         = <<EOF
_sourceCategory="lab/okta/system" app.oauth2.client.lifecycle.create
| where eventType="app.oauth2.client.lifecycle.create"
    and %"outcome.result"="SUCCESS"
| json field=_raw "target[0].detailEntry.redirecturis" as redirect_uris nodrop
| json field=_raw "target[0].detailEntry.granttypes" as grant_types nodrop
| json field=_raw "target[0].detailEntry.responsetypes" as response_types nodrop
| json field=_raw "target[0].detailEntry.tokenendpointauthmethod" as token_auth_method nodrop
| json field=_raw "target[0].detailEntry.applicationtype" as application_type nodrop
| json field=_raw "debugContext.debugData.requestId" as request_id nodrop
| %"actor.alternateId" as actor_login
| %"actor.displayName" as actor_name
| %"actor.id" as actor_user_id
| %"client.ipAddress" as client_ip
| %"authenticationContext.externalSessionId" as actor_session_id
| %"target[0].id" as app_id
| %"target[0].displayName" as app_label
| eventType as event_type
| %"outcome.result" as outcome
| count as matched_events by uuid, published, event_type, outcome, request_id, actor_login, actor_name, actor_user_id, client_ip, actor_session_id, app_id, app_label, application_type, redirect_uris, grant_types, response_types, token_auth_method
| fields uuid, published, event_type, outcome, request_id, actor_login, actor_name, actor_user_id, client_ip, actor_session_id, app_id, app_label, application_type, redirect_uris, grant_types, response_types, token_auth_method
| sort by published desc
| limit 1
EOF
  standard_folder        = sumologic_monitor_folder.detections.id
  tines_webhook          = sumologic_connection.tines_webhook.id
  standard_trigger_type  = "Warning"
  tines_webhook_override = <<EOF
{
  "monitor_name": "{{Name}}",
  "monitor_description": "{{Description}}",
  "detection_severity": "Medium",
  "severity_rationale": "A new OAuth client with an unapproved redirect URI is Medium; Tines raises the assessment to High when the application is active and refresh-token capable because it can sustain delegated access without repeated user interaction.",
  "expected_false_positive": "A newly onboarded legitimate SaaS or OIDC integration whose callback domain has not yet been added to the approved redirect inventory.",
  "mitre_techniques": "T1098.001 - Additional Cloud Credentials; T1528 - Steal Application Access Token (when token grant or use is confirmed)",
  "investigation_playbook": "Validate the application owner and change record; review every redirect URI, grant and response type; confirm status, assignment and consent; pivot on the actor ID, session and source IP; search for client privilege grants, secret reads and token issuance or use; deactivate an unauthorised application and revoke associated grants or tokens.",
  "query_url": "{{QueryURL}}",
  "query": "{{Query}}",
  "trigger_time_range": "{{TriggerTimeRange}}",
  "trigger_time": "{{TriggerTime}}",
  "results": "{{ResultsJson}}"
}
EOF
}
