# 05 — Security, Privacy, and Testing

## 1. Security objective

Protect child users, session integrity, research records, and the existing Si-Cehat application while embedding a web game in Flutter.

Security controls must be implemented throughout development, not postponed until the final release.

## 2. Threat model and mitigations

| Threat | Required mitigation |
|---|---|
| Client manipulates score | Backend recomputes or validates results from submitted answers and versioned rules. |
| Duplicate completion/reward | Idempotency keys or unique constraints and transactional persistence. |
| Cross-profile session access | Verify ownership and authorization on every session endpoint. |
| Untrusted page uses native bridge | Strict origin allowlist; external pages receive no privileged bridge. |
| Long-lived token leaks through URL/logs | Use a short-lived bootstrap exchange; redact secrets from logs. |
| Malformed or oversized bridge message | Schema validation, allowlisted message types, and payload size limits. |
| Research export exposes identifiers | Role/study-level access, pseudonymization where appropriate, and export audit trail. |
| Game changes during study | Pin and record versions; document and review any change. |
| Network retry duplicates data | Idempotent endpoints and deduplication identifiers. |
| Sensitive data appears in logs | Structured redaction and logging policy. |

## 3. WebView hardening

- Restrict navigation to the approved game origin.
- Open external URLs outside the privileged WebView or block them.
- Do not enable file access or cross-file access unless explicitly required and reviewed.
- Do not expose privileged native methods to arbitrary web content.
- Validate all bridge messages and session context.
- Use HTTPS in production.
- Do not put long-lived access or refresh tokens in URLs.
- Avoid storing sensitive credentials in `localStorage`.
- Handle app background/resume and session expiry.
- Keep WebView and dependencies updated according to the project’s maintenance policy.

## 4. Authentication and authorization

- Reuse the existing Si-Cehat authentication flow where possible.
- Derive identity from the authenticated context rather than trusting arbitrary profile IDs from the client.
- Verify access to the game session on every read/write request.
- Apply least-privilege roles for researcher/admin exports.
- Prevent access across profiles and studies.
- Use short-lived session bootstrap data if required.
- Define revocation/expiry behavior.
- Avoid returning internal authorization details in errors.

## 5. Privacy requirements

- Define the purpose for every stored field and analytics event.
- Collect the minimum data necessary.
- Use participant codes for research exports when appropriate.
- Store identity mapping separately and restrict access.
- Define retention and deletion procedures.
- Redact tokens and unnecessary identifiers from logs.
- Avoid putting real child data in fixtures, screenshots, test logs, or development datasets.
- Apply the appropriate parent/guardian permission and child-assent procedures required by the study and applicable rules.
- Document incident handling and access review.

## 6. Test strategy

### 6.1 Unit tests

Test:
- Game scoring rules.
- Answer validation.
- Version-specific scoring.
- State transitions.
- Payload schema validation.
- Result formatting.

### 6.2 API integration tests

Test:
- Session creation.
- Authorized event submission.
- Session completion and canonical result retrieval.
- Duplicate completion.
- Invalid/expired session.
- Invalid game/instrument version.
- Malformed or oversized payload.
- Rate limiting where configured.
- Transaction behavior if result and reward are stored together.

### 6.3 Authorization/security tests

Test:
- Unauthenticated requests.
- User attempts to access another user’s session.
- Profile/participant mismatch.
- Researcher without study access requests export.
- Unexpected WebView origin and bridge message.
- Tampered score or answer payload.
- Token and direct-identifier leakage in logs.

### 6.4 Flutter/WebView tests

Test on supported real devices:
- Launch and ready state.
- Back navigation and exit.
- App background/resume.
- Reload behavior.
- Network offline/online transitions.
- Session expiry.
- Small and large screens.
- Touch targets and drag/drop behavior.
- Web asset loading failure.
- Result refresh after completion.

### 6.5 Data quality tests

Test:
- One canonical final result per session where required.
- Retry does not duplicate result or reward.
- Game/content/rules/instrument versions are preserved.
- Incomplete sessions remain explicitly incomplete.
- Export contains only approved fields.
- Participant code links the intended records without exposing direct identity unnecessarily.

## 7. Initial usability test

A small formative test, for example 5–8 children from the intended population, may help identify usability issues. This is a suggested starting point, not a statistically powered effectiveness sample. Conduct it only under the appropriate permissions and safeguarding procedures.

Observe:
- Whether instructions are understood.
- Whether touch/drag interactions are usable.
- Whether the child can complete the flow without excessive help.
- Whether feedback is understood.
- Whether navigation and exit behavior are clear.
- Whether any content causes confusion or discomfort.
- Whether device performance or connectivity interrupts play.

Record observations using participant codes and avoid unnecessary video, audio, or identifying data.

## 8. Release gates

Do not proceed to a participant pilot until:
- No unresolved critical gameplay or data-loss defect remains.
- Session ownership and result validation tests pass.
- Duplicate completion is handled safely.
- WebView origin and bridge restrictions are verified.
- Game and assessment versions are traceable.
- Export access controls are tested.
- Required study/ethics and child-protection procedures are approved.
- Known limitations and incident contacts are documented.

## 9. Bug severity guidance

- **Critical:** unauthorized data access, cross-participant disclosure, score/result integrity failure, or data loss affecting research records.
- **High:** core game cannot be completed, sessions consistently fail, or result submission is unreliable.
- **Medium:** significant usability issue with a workaround.
- **Low:** cosmetic issue or minor non-blocking inconsistency.

Critical and high-severity issues should be resolved before the pilot unless the study owner and responsible technical/security reviewers explicitly approve a documented mitigation.

## 10. Test reporting

The coding agent must report:
- Tests actually run and their commands.
- Pass/fail results.
- Device/browser/OS context for manual tests.
- Known failures and untested areas.
- Migration/test database details.
- Residual risks and recommended next steps.

Never claim tests passed if they were not executed. Technical test success does not prove educational effectiveness.
