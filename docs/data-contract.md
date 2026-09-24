# Sumo-to-Tines data contract

Sumo sends one JSON webhook object to Tines:

| Field | Purpose |
| --- | --- |
| `monitor_name` | Human-readable detection name |
| `monitor_description` | Playbook summary |
| `detection_severity` | Base analyst-facing classification |
| `severity_rationale` | Reason the detection uses that classification |
| `expected_false_positive` | Credible benign explanation for analyst validation |
| `mitre_techniques` | Relevant MITRE ATT&CK tactics and techniques |
| `investigation_playbook` | Concise response and investigation sequence |
| `query_url` | Link back to Sumo evidence |
| `query` | Deployed Sumo query |
| `trigger_time_range` | Evaluation window |
| `trigger_time` | Alert time |
| `results` | JSON-encoded normalised result rows |

Tines parses `results`, selects the first aggregate row and deduplicates on the Okta System Log `uuid`.

## PB-100 result fields

`uuid`, `published`, `event_type`, `outcome`, `actor_login`, `actor_name`, `actor_user_id`, `client_ip`, `actor_session_id`, `target_user_id`, `target_login`, `granted_role`

## PB-200 result fields

`uuid`, `published`, `event_type`, `outcome`, `request_id`, `actor_login`, `actor_name`, `actor_user_id`, `client_ip`, `actor_session_id`, `app_id`, `app_label`, `application_type`, `redirect_uris`, `grant_types`, `response_types`, `token_auth_method`

Both monitor queries aggregate on the projected field set before invoking `ResultsJson`. This prevents Sumo's raw `Message` field from entering the webhook payload. That safeguard is important for PB-200 because the originating Okta event can contain client-secret material.

PB-200 uses `app.oauth2.client.lifecycle.create`, whose `target[0].detailEntry` contains the registration-time redirect and grant details in the tested Okta tenant. Tines then retrieves `/api/v1/apps/{app_id}` to validate the application's authoritative current status, redirect URI array, grants and client-authentication method before making a response decision.
