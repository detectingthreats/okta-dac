module "rule_okta_administrator_role_assigned_to_non_admin_user_account" {
  source                 = "./modules/sumo_monitor"
  standard_name          = "DAC - Okta Admin Role Granted to Non-Admin User"
  standard_description   = "PB-100 [High]: Detects a successful administrator-role grant to an Okta identity outside the approved admin.* naming convention. Validate the change, investigate the actor session and related persistence activity, and contain only under the controlled response policy."
  standard_query         = <<EOF
_sourceCategory="lab/okta/system" user.account.privilege.grant
| where eventType="user.account.privilege.grant"
    and %"outcome.result"="SUCCESS"
    and !(%"target[0].alternateId" matches /^admin\./)
    and %"target[0].alternateId" != "username@trustedthirdparty.com"
| %"actor.alternateId" as actor_login
| %"actor.displayName" as actor_name
| %"actor.id" as actor_user_id
| %"client.ipAddress" as client_ip
| if(isNull(client_ip), "Not supplied by Okta on this event", client_ip) as client_ip
| %"authenticationContext.externalSessionId" as actor_session_id
| %"target[0].id" as target_user_id
| %"target[0].alternateId" as target_login
| %"target[2].displayName" as granted_role
| eventType as event_type
| %"outcome.result" as outcome
| count as matched_events by uuid, published, event_type, outcome, actor_login, actor_name, actor_user_id, client_ip, actor_session_id, target_user_id, target_login, granted_role
| fields uuid, published, event_type, outcome, actor_login, actor_name, actor_user_id, client_ip, actor_session_id, target_user_id, target_login, granted_role
| sort by published desc
| limit 1
EOF
  standard_folder        = sumologic_monitor_folder.detections.id
  tines_webhook          = sumologic_connection.tines_webhook.id
  standard_trigger_type  = "Critical"
  tines_webhook_override = <<EOF
{
  "monitor_name": "{{Name}}",
  "monitor_description": "{{Description}}",
  "detection_severity": "High",
  "severity_rationale": "A single successful administrator-role grant changes control-plane access and can establish a persistent privileged identity.",
  "expected_false_positive": "An authorised third-party support identity or approved emergency elevation that has not yet been added to the managed exception list.",
  "mitre_techniques": "T1098 - Account Manipulation; T1098.003 - Additional Cloud Roles",
  "investigation_playbook": "Validate the approved change; verify the actor independently; pivot on actor ID, session and source IP; review further role grants, API-token creation, application changes and client-secret reads; check the target's subsequent sign-ins and actions; preserve evidence and contain confirmed compromise.",
  "query_url": "{{QueryURL}}",
  "query": "{{Query}}",
  "trigger_time_range": "{{TriggerTimeRange}}",
  "trigger_time": "{{TriggerTime}}",
  "results": "{{ResultsJson}}"
}
EOF
}
