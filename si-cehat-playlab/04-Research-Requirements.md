# 04 — Research Requirements

## 1. Purpose and limitation

The game may support evaluation of health knowledge, usability, engagement, and retention. Technical logs alone do not demonstrate learning effectiveness or real-world behavior change.

The study owner and appropriate research/ethics reviewers must approve the protocol, participant population, consent process, assessment instrument, sample size, analysis plan, and data management plan before participant data is collected.

## 2. Proposed research objectives

Primary objective:
- Evaluate change in knowledge related to the game’s approved learning objective.

Secondary objectives, if included in the protocol:
- Assess usability and completion.
- Describe engagement and interaction patterns.
- Assess retention at a planned follow-up.
- Identify usability barriers and content misconceptions.

Do not include objectives merely because the app can collect the data. Each measure should answer a defined research question.

## 3. Measurement domains

### Primary: knowledge

- Pre-test and post-test scores using an age-appropriate instrument.
- Instrument should be reviewed or validated for the intended population and purpose.
- Record instrument version and scoring rules.
- Keep assessment results separate from gameplay performance.

### Process measures

Possible measures:
- Session completion.
- Session duration.
- Number of attempts.
- Hint use.
- Selected responses needed to interpret the learning process.
- Technical failures or incomplete submissions.

### Usability

Possible measures:
- Instruction comprehension.
- Ability to complete interactions without help.
- Navigation errors.
- Need for adult assistance.
- Device and accessibility barriers.

### Retention

If the protocol requires it, a follow-up assessment may be scheduled, for example 7–14 days later. The interval must be set by the study owner, not assumed by the software team.

## 4. Proposed evaluation flow

- **T0 — Pre-test:** measure knowledge before exposure to the intervention.
- **Intervention:** participant plays the versioned game under standardized instructions and conditions.
- **T1 — Post-test:** measure knowledge using the approved assessment procedure.
- **T2 — Follow-up:** measure retention if included in the protocol.

The assessment may live in the app, the game, or a separate research workflow depending on the approved protocol. Avoid duplicating assessment screens in ways that create inconsistent timing or data.

## 5. Study design considerations

A one-group pre-test/post-test design cannot rule out repeated-test effects, maturation, or other exposure. If the goal is to claim that the game caused a change, consider an appropriate comparison group and a pre-specified analysis plan.

The research lead must determine:
- Study design and comparison condition.
- Sample-size rationale.
- Inclusion/exclusion criteria.
- Assessment instrument and scoring.
- Missing-data policy.
- Statistical analysis.
- Follow-up timing.
- Criteria for feasibility and progression to a larger study.

A small usability pilot is useful for finding interaction problems but is not a sufficient sample or design to establish educational effectiveness.

## 6. Version traceability

For every relevant session or assessment, store:
- Game version.
- Content version.
- Rules/scoring version.
- Instrument version.
- Study/protocol identifier where appropriate.
- Session/attempt status.
- Timestamps needed for the approved analysis.

Lock versions during a study when possible. Any change to content, scoring, or assessment must be documented and reviewed for its impact on the protocol and comparability of participants.

## 7. Event tracking principles

- Define each event and its research purpose before implementation.
- Collect the minimum necessary data.
- Avoid recording every pointer movement.
- Do not place direct child identifiers in event payloads.
- Avoid raw assessment answers in operational logs.
- Define timestamp handling and deduplication.
- Mark incomplete or technically failed sessions explicitly.
- Do not fabricate missing values or infer completion when the server has not confirmed it.

Candidate event names include:
- `game_started`
- `round_started`
- `item_selected`
- `hint_used`
- `round_completed`
- `knowledge_check_submitted`
- `game_completion_requested`
- `game_completion_confirmed`
- `game_error`

The final list should be tailored to the protocol.

## 8. Data export

Research exports should:
- Be limited to authorized users and the appropriate study.
- Use a participant code where feasible.
- Exclude direct identifiers unless specifically approved and necessary.
- Include codebook and version fields.
- Include status/missingness indicators.
- Use a documented file format and schema.
- Be logged as an access event without logging the full sensitive dataset.

The mapping between an app identity and a participant code should be stored separately with tighter access control. Pseudonymized data is not automatically anonymous.

## 9. Child-participant protections

Before collecting research data:
- Confirm the applicable ethics review and institutional requirements.
- Obtain parent/guardian permission and age-appropriate child assent as required.
- Explain the activity in language appropriate to the child.
- Make withdrawal and stopping procedures clear.
- Define who may access raw data.
- Define retention, deletion, and incident-response procedures.
- Avoid collecting unnecessary health or behavioral information.
- Ensure the game does not shame, pressure, or manipulate children into extended play.

Use of the app does not automatically equal consent to participate in research.

## 10. Research acceptance criteria

- Protocol and assessment procedures are approved by the study owner.
- Game/instrument versions are traceable.
- Pre/post or follow-up records can be linked using the approved participant identifier.
- Missing and failed submissions are represented explicitly.
- Export fields match the data management plan.
- Access to identity mapping and exports is restricted.
- Pilot findings are reported as feasibility/usability findings, not as proof of effectiveness.
