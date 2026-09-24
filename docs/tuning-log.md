# Detection tuning record

## PB-100 — Administrator role granted to a non-admin identity

| # | Tuning decision | Status | Notes |
| --- | --- | --- | --- |
| 1 | Require `outcome.result=SUCCESS`. | Implemented | A failed request did not change privileges. |
| 2 | Exclude the trusted-party identity `username@trustedthirdparty.com`. | Implemented | Example of a documented business exception. Consider a governed lookup as the exception set grows because inline exclusions become difficult to manage at scale. |

## PB-200 — New OAuth application requires redirect review

| # | Tuning decision | Status | Notes |
| --- | --- | --- | --- |
| 1 | Add `https://oauth.legitimatecompany.com/callback` to the approved redirect inventory. | Example | Representative post-deployment allow-list change. This remains an illustrative tuning example because an exception should not be implemented without a corresponding approved integration. |
