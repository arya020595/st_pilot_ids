# Entity Relationship Diagram — ST Pilot IDS

> **Updated**: 2026-03-18
> **Format**: Text-based (table definitions + relationship notation)
> **Coverage**: Phase 1 (implemented) + Phase 2 (planned), with design recommendations

---

## Table of Contents

1. [Implementation Status](#implementation-status)
2. [Phase 1 — Current Schema (Implemented)](#phase-1--current-schema-implemented)
3. [Phase 2 — Planned Schema](#phase-2--planned-schema)
4. [Full Relationship Map](#full-relationship-map)
5. [Design Recommendations](#design-recommendations)
6. [KPI Weight Strategy](#kpi-weight-strategy)

---

## Implementation Status

| Table                      | Status         | Phase | Notes                                                     |
| -------------------------- | -------------- | ----- | --------------------------------------------------------- |
| `permissions`              | ✅ Implemented | 1     |                                                           |
| `role_permissions`         | ✅ Implemented | 1     | Join table (N:M roles ↔ permissions)                      |
| `roles`                    | ✅ Implemented | 1     |                                                           |
| `staff_profiles`           | ✅ Implemented | 1     | Custom PK: `staff_profile_id`, read-only import           |
| `users`                    | ✅ Implemented | 1     | Devise auth; `staff_profile_id` FK pending                |
| `ids_staffs`               | 🔲 Planned     | 2     | Master data / raw staff import                            |
| `kpi_assessments`          | 🔲 Planned     | 2     |                                                           |
| `quarters`                 | 🔲 Planned     | 2     | `year` + `quarter_name` columns; FK direction resolved ✅ |
| `quality_based_kpis`       | 🔲 Planned     | 2     |                                                           |
| `quantity_based_kpis`      | 🔲 Planned     | 2     |                                                           |
| `research_work_relateds`   | 🔲 Planned     | 2     | Sub-score table for quality KPI                           |
| `financial_managements`    | 🔲 Planned     | 2     | Sub-score table for quality KPI                           |
| `soft_skills`              | 🔲 Planned     | 2     | Sub-score table for quality KPI                           |
| `hard_skills`              | 🔲 Planned     | 2     | Sub-score table for quality KPI                           |
| `other_involvements`       | 🔲 Planned     | 2     | Sub-score table for quality KPI                           |
| `output_and_impact_baseds` | 🔲 Planned     | 2     | Sub-score table for quantity KPI                          |
| `psychometric_assessments` | 🔲 Planned     | 2     |                                                           |

---

## Phase 1 — Current Schema (Implemented)

> These tables exist in `db/schema.rb` and are fully operational.

---

### `permissions`

| Column       | Type     | Constraints        | Notes                              |
| ------------ | -------- | ------------------ | ---------------------------------- |
| `id`         | bigint   | PK, auto-increment |                                    |
| `code`       | string   | NOT NULL, UNIQUE   | e.g. `user_management.users.index` |
| `name`       | string   | NOT NULL           | Human-readable label               |
| `created_at` | datetime | NOT NULL           |                                    |
| `updated_at` | datetime | NOT NULL           |                                    |

**Indexes**: `index_permissions_on_code` (unique)

---

### `roles`

| Column       | Type     | Constraints        | Notes                      |
| ------------ | -------- | ------------------ | -------------------------- |
| `id`         | bigint   | PK, auto-increment |                            |
| `name`       | string   | NOT NULL, UNIQUE   | e.g. `superadmin`, `staff` |
| `created_at` | datetime | NOT NULL           |                            |
| `updated_at` | datetime | NOT NULL           |                            |

**Indexes**: `index_roles_on_name` (unique)

---

### `role_permissions` _(join table)_

| Column          | Type     | Constraints                     | Notes |
| --------------- | -------- | ------------------------------- | ----- |
| `id`            | bigint   | PK, auto-increment              |       |
| `role_id`       | bigint   | NOT NULL, FK → `roles.id`       |       |
| `permission_id` | bigint   | NOT NULL, FK → `permissions.id` |       |
| `created_at`    | datetime | NOT NULL                        |       |
| `updated_at`    | datetime | NOT NULL                        |       |

**Indexes**: `(role_id, permission_id)` unique composite; `role_id`; `permission_id`
**Foreign keys**: `role_id` → `roles`, `permission_id` → `permissions`

---

### `users`

| Column                   | Type     | Constraints               | Notes                     |
| ------------------------ | -------- | ------------------------- | ------------------------- |
| `id`                     | bigint   | PK, auto-increment        |                           |
| `email`                  | string   | NOT NULL, UNIQUE          | Devise auth               |
| `encrypted_password`     | string   | NOT NULL                  | Devise                    |
| `name`                   | string   |                           |                           |
| `role_id`                | bigint   | FK → `roles.id`, nullable | `null` = no role assigned |
| `is_active`              | boolean  | default: `true`           |                           |
| `reset_password_token`   | string   | UNIQUE                    | Devise                    |
| `reset_password_sent_at` | datetime |                           | Devise                    |
| `remember_created_at`    | datetime |                           | Devise                    |
| `sign_in_count`          | integer  | NOT NULL, default: `0`    | Devise trackable          |
| `current_sign_in_at`     | datetime |                           | Devise trackable          |
| `last_sign_in_at`        | datetime |                           | Devise trackable          |
| `current_sign_in_ip`     | string   |                           | Devise trackable          |
| `last_sign_in_ip`        | string   |                           | Devise trackable          |
| `created_at`             | datetime | NOT NULL                  |                           |
| `updated_at`             | datetime | NOT NULL                  |                           |

> ⚠️ **Pending (Phase 2)**: Add `staff_profile_id` FK column linking a user account to their staff profile.

**Indexes**: `email` (unique), `reset_password_token` (unique), `role_id`
**Foreign keys**: `role_id` → `roles`

---

### `staff_profiles`

> Read-only. Imported from IDS. Custom primary key.

| Column              | Type     | Constraints                     | Notes                           |
| ------------------- | -------- | ------------------------------- | ------------------------------- |
| `staff_profile_id`  | bigint   | **PK** (custom), auto-increment | Declared via `self.primary_key` |
| `email`             | string   | NOT NULL, UNIQUE                |                                 |
| `fullname`          | string   | NOT NULL                        |                                 |
| `grade`             | string   | NOT NULL                        |                                 |
| `position`          | string   | NOT NULL                        |                                 |
| `division`          | string   | NOT NULL                        |                                 |
| `supervisor_name`   | string   | NOT NULL                        |                                 |
| `employment_level`  | string   | NOT NULL                        |                                 |
| `no_of_subordinate` | integer  | NOT NULL, default: `0`          |                                 |
| `created_at`        | datetime | NOT NULL                        |                                 |
| `updated_at`        | datetime | NOT NULL                        |                                 |

**Indexes**: `email` (unique), `grade`, `position`, `division`

---

## Phase 2 — Planned Schema

> Tables below are derived from the target ERD design. None exist in `db/schema.rb` yet. All require migrations.

---

### `ids_staffs`

> Raw staff master data imported from IDS system. Basis for KPI / psychometric assessments.
> Decision: Keep separate from `staff_profiles` (see [Design Recommendations §4](#4-ids_staffs-vs-staff_profiles-overlap)).

| Column            | Type     | Constraints        | Notes                                                   |
| ----------------- | -------- | ------------------ | ------------------------------------------------------- |
| `id`              | bigint   | PK, auto-increment |                                                         |
| `staff_code`      | string   | NOT NULL, UNIQUE   | External IDS identifier, e.g. `"STF_001"` (shown in UI) |
| `email`           | string   | NOT NULL, UNIQUE   |                                                         |
| `fullname`        | string   | NOT NULL           |                                                         |
| `grade`           | string   | NOT NULL           |                                                         |
| `department_unit` | string   | NOT NULL           |                                                         |
| `position`        | string   | NOT NULL           |                                                         |
| `created_at`      | datetime | NOT NULL           |                                                         |
| `updated_at`      | datetime | NOT NULL           |                                                         |

**Indexes**: `staff_code` (unique), `email` (unique)

> See [Design Recommendations §4](#4-ids_staffs-vs-staff_profiles-overlap) for the distinction from `staff_profiles`.

---

### `kpi_assessments`

> **Decision**: No snapshot columns. JOIN to `ids_staffs` for display. See [Design Recommendations §3](#3-kpi_assessments-denormalization).
> `updated_at` is used as the "Reviewed At" display value in the Level 2 staff listing.

| Column         | Type     | Constraints                    | Notes                           |
| -------------- | -------- | ------------------------------ | ------------------------------- |
| `id`           | bigint   | PK, auto-increment             |                                 |
| `ids_staff_id` | bigint   | NOT NULL, FK → `ids_staffs.id` | The assessed staff member       |
| `created_at`   | datetime | NOT NULL                       |                                 |
| `updated_at`   | datetime | NOT NULL                       | Used as "Reviewed At" in the UI |

**Indexes**: `ids_staff_id`
**Foreign keys**: `ids_staff_id` → `ids_staffs`

---

### `quarters`

> Reference / seed data. Exists independently of any assessment. Q1–Q4 per year, seeded for 2024–2030.
> FK direction: the scoring tables (`quality_based_kpis`, `quantity_based_kpis`) reference `quarter_id`. See [Design Recommendations §2](#2-quarter-fk-direction).

| Column         | Type     | Constraints        | Notes                                                      |
| -------------- | -------- | ------------------ | ---------------------------------------------------------- |
| `id`           | bigint   | PK, auto-increment |                                                            |
| `quarter_name` | string   | NOT NULL           | `"Quarter 1"`, `"Quarter 2"`, `"Quarter 3"`, `"Quarter 4"` |
| `year`         | integer  | NOT NULL           | e.g. `2024`, `2025`, `2026`                                |
| `created_at`   | datetime | NOT NULL           |                                                            |
| `updated_at`   | datetime | NOT NULL           |                                                            |

**Indexes**: `(quarter_name, year)` unique composite

> `display_name` helper: `"#{year} : #{quarter_name}"` → `"2025 : Quarter 1"` (used in breadcrumbs and dropdowns)

---

### `quality_based_kpis`

| Column                    | Type         | Constraints                         | Notes                        |
| ------------------------- | ------------ | ----------------------------------- | ---------------------------- |
| `id`                      | bigint       | PK, auto-increment                  |                              |
| `kpi_assessment_id`       | bigint       | NOT NULL, FK → `kpi_assessments.id` |                              |
| `quarter_id`              | bigint       | NOT NULL, FK → `quarters.id`        | Replaces ERD's inverted FK   |
| `overall_total`           | decimal(5,2) |                                     | Computed or stored overall % |
| `research_work_id`        | bigint       | FK → `research_work_relateds.id`    |                              |
| `financial_management_id` | bigint       | FK → `financial_managements.id`     |                              |
| `soft_skill_id`           | bigint       | FK → `soft_skills.id`               |                              |
| `hard_skill_id`           | bigint       | FK → `hard_skills.id`               |                              |
| `other_involvement_id`    | bigint       | FK → `other_involvements.id`        |                              |
| `created_at`              | datetime     | NOT NULL                            |                              |
| `updated_at`              | datetime     | NOT NULL                            |                              |

---

### `quantity_based_kpis`

| Column                       | Type         | Constraints                         | Notes                      |
| ---------------------------- | ------------ | ----------------------------------- | -------------------------- |
| `id`                         | bigint       | PK, auto-increment                  |                            |
| `kpi_assessment_id`          | bigint       | NOT NULL, FK → `kpi_assessments.id` |                            |
| `quarter_id`                 | bigint       | NOT NULL, FK → `quarters.id`        | Replaces ERD's inverted FK |
| `overall_total`              | decimal(5,2) |                                     |                            |
| `output_and_impact_based_id` | bigint       | FK → `output_and_impact_baseds.id`  |                            |
| `created_at`                 | datetime     | NOT NULL                            |                            |
| `updated_at`                 | datetime     | NOT NULL                            |                            |

---

### `research_work_relateds`

> Sub-score component for Quality-Based KPI — Section A.

| Column                     | Type         | Constraints | Notes                         |
| -------------------------- | ------------ | ----------- | ----------------------------- |
| `id`                       | bigint       | PK          |                               |
| `proposal_preparation`     | decimal(5,2) |             | Full score: 10%               |
| `proposal_presentation`    | decimal(5,2) |             | Full score: 10%               |
| `data_collection`          | decimal(5,2) |             | Full score: 10%               |
| `data_entry_and_cleaning`  | decimal(5,2) |             | Full score: 10%               |
| `report_writing`           | decimal(5,2) |             | Full score: 30%               |
| `analysis_of_data`         | decimal(5,2) |             | Full score: 15%               |
| `presentation_of_findings` | decimal(5,2) |             | Full score: 15%               |
| `total_score`              | decimal(5,2) |             | Weightage: **70%** of quality |
| `created_at`               | datetime     | NOT NULL    |                               |
| `updated_at`               | datetime     | NOT NULL    |                               |

---

### `financial_managements`

> Sub-score component for Quality-Based KPI — Section B.

| Column                | Type         | Constraints | Notes                         |
| --------------------- | ------------ | ----------- | ----------------------------- |
| `id`                  | bigint       | PK          |                               |
| `budgeting`           | decimal(5,2) |             | Full score: 25%               |
| `record_keeping`      | decimal(5,2) |             | Full score: 25%               |
| `cashflow_management` | decimal(5,2) |             | Full score: 25%               |
| `compliance`          | decimal(5,2) |             | Full score: 25%               |
| `total_score`         | decimal(5,2) |             | Weightage: **10%** of quality |
| `created_at`          | datetime     | NOT NULL    |                               |
| `updated_at`          | datetime     | NOT NULL    |                               |

---

### `soft_skills`

> Sub-score component for Quality-Based KPI — Section C.

| Column                  | Type         | Constraints | Notes                         |
| ----------------------- | ------------ | ----------- | ----------------------------- |
| `id`                    | bigint       | PK          |                               |
| `writing_skill`         | decimal(5,2) |             | Full score: 20%               |
| `presentation_skill`    | decimal(5,2) |             | Full score: 20%               |
| `computer_skill`        | decimal(5,2) |             | Full score: 20%               |
| `management_skill`      | decimal(5,2) |             | Full score: 20%               |
| `statistical_knowledge` | decimal(5,2) |             | Full score: 20%               |
| `total_score`           | decimal(5,2) |             | Weightage: **10%** of quality |
| `created_at`            | datetime     | NOT NULL    |                               |
| `updated_at`            | datetime     | NOT NULL    |                               |

---

### `hard_skills`

> Sub-score component for Quality-Based KPI — Section D.

| Column                   | Type         | Constraints | Notes                        |
| ------------------------ | ------------ | ----------- | ---------------------------- |
| `id`                     | bigint       | PK          |                              |
| `communication_skill`    | decimal(5,2) |             | Full score: 20%              |
| `collaboration_teamwork` | decimal(5,2) |             | Full score: 20%              |
| `problem_solving`        | decimal(5,2) |             | Full score: 20%              |
| `leadership`             | decimal(5,2) |             | Full score: 20%              |
| `attention_details`      | decimal(5,2) |             | Full score: 20%              |
| `total_score`            | decimal(5,2) |             | Weightage: **5%** of quality |
| `created_at`             | datetime     | NOT NULL    |                              |
| `updated_at`             | datetime     | NOT NULL    |                              |

---

### `other_involvements`

> Sub-score component for Quality-Based KPI — Section E.

| Column                      | Type         | Constraints | Notes                        |
| --------------------------- | ------------ | ----------- | ---------------------------- |
| `id`                        | bigint       | PK          |                              |
| `ideas_platform`            | decimal(5,2) |             | Full score: 25%              |
| `any_social_media_platform` | decimal(5,2) |             | Full score: 25%              |
| `ids_watch_column`          | decimal(5,2) |             | Full score: 25%              |
| `others`                    | decimal(5,2) |             | Full score: 25%              |
| `total_score`               | decimal(5,2) |             | Weightage: **5%** of quality |
| `created_at`                | datetime     | NOT NULL    |                              |
| `updated_at`                | datetime     | NOT NULL    |                              |

---

### `output_and_impact_baseds`

> Sub-score component for Quantity-Based KPI.

| Column                        | Type         | Constraints | Notes                           |
| ----------------------------- | ------------ | ----------- | ------------------------------- |
| `id`                          | bigint       | PK          |                                 |
| `number_of_involvement`       | decimal(5,2) |             | Full score: 20%                 |
| `output_production`           | decimal(5,2) |             | Full score: 30%                 |
| `acceptance_of_outputs`       | decimal(5,2) |             | Full score: 15%                 |
| `uptake_of_outputs`           | decimal(5,2) |             | Full score: 10%                 |
| `presentation_state_level`    | decimal(5,2) |             | Full score: 10%                 |
| `presentation_national_level` | decimal(5,2) |             | Full score: 15%                 |
| `total_score`                 | decimal(5,2) |             | Weightage: **100%** of quantity |
| `created_at`                  | datetime     | NOT NULL    |                                 |
| `updated_at`                  | datetime     | NOT NULL    |                                 |

---

### `psychometric_assessments`

> **Decision**: No snapshot columns. JOIN to `ids_staffs` for display (same policy as `kpi_assessments`).
> PDF stored via Rails Active Storage — no file path column in this table.

| Column         | Type     | Constraints                    | Notes                          |
| -------------- | -------- | ------------------------------ | ------------------------------ |
| `id`           | bigint   | PK, auto-increment             |                                |
| `ids_staff_id` | bigint   | NOT NULL, FK → `ids_staffs.id` | Links to assessed staff member |
| `created_at`   | datetime | NOT NULL                       |                                |
| `updated_at`   | datetime | NOT NULL                       |                                |

**Indexes**: `ids_staff_id`
**Foreign keys**: `ids_staff_id` → `ids_staffs`
**Active Storage**: attach PDF via `has_one_attached :uploaded_pdf_file` in the model (see [Design Recommendations §8](#8-uploaded_pdf_file--use-active-storage)). No file path column needed.

---

## Full Relationship Map

```
Phase 1 (Implemented)
─────────────────────
roles           ||--o{  users                  : "has many"
roles           ||--o{  role_permissions       : "has many"
permissions     ||--o{  role_permissions       : "has many"
users           }o--||  roles                  : "belongs to (optional)"


Phase 2 (Planned)
─────────────────────────────────────────────────────────────
users                   }o--o|  staff_profiles         : "linked account (FK pending)"
ids_staffs              ||--o{  kpi_assessments         : "has many"
ids_staffs              ||--o{  psychometric_assessments: "has many (FK: ids_staff_id)"


kpi_assessments         ||--o{  quality_based_kpis      : "has many (per quarter)"
kpi_assessments         ||--o{  quantity_based_kpis     : "has many (per quarter)"

quarters                ||--o{  quality_based_kpis      : "used in"
quarters                ||--o{  quantity_based_kpis     : "used in"

quality_based_kpis      ||--||  research_work_relateds  : "has one (section A)"
quality_based_kpis      ||--||  financial_managements   : "has one (section B)"
quality_based_kpis      ||--||  soft_skills             : "has one (section C)"
quality_based_kpis      ||--||  hard_skills             : "has one (section D)"
quality_based_kpis      ||--||  other_involvements      : "has one (section E)"

quantity_based_kpis     ||--||  output_and_impact_baseds: "has one"
```

---

## Design Recommendations

### 1. Keep `role_permissions` Join Table

The original ERD image omits `role_permissions` and implies a direct `permissions.role_id` column (1:N). The current implementation uses a **join table** (N:M), which is more correct and flexible — a permission code can be shared across multiple roles. **Do not change this.**

---

### 2. Quarter FK Direction ✅ RESOLVED

**Was**: The original ERD placed `kpi_assessment_id` on `quarters`, making each quarter a child of an assessment — inverted dependency.

**Decision**: Quarters are independent reference data. The FK sits on the scoring tables:

```
quality_based_kpis.quarter_id  → quarters   ✅
quantity_based_kpis.quarter_id → quarters   ✅
```

Quarters are seeded once (`db/seeds/05_quarters.rb`) as `Quarter 1`–`Quarter 4` for each year 2024–2030. The `quarters` table now has a `year` integer column for efficient grouping on the index page. The planned schema above already reflects this.

---

### 3. `kpi_assessments` Denormalization ✅ RESOLVED

**Decision**: **Remove snapshot columns.** `kpi_assessments` stores only `ids_staff_id`. All display data (name, position, grade) is JOINed from `ids_staffs` at query time.

**Rationale**:

- IDS master data is managed centrally; staff records do not change retroactively.
- Avoids sync issues between two copies of the same data.
- Simpler migration, simpler model.

Same decision applies to `psychometric_assessments` (see §4 above).

> If a future requirement emerges to preserve a historical snapshot of staff details at the time of assessment, add an explicit `position_at_time_of_assessment` column (single purpose, clearly named) rather than copying all fields.

---

### 4. `ids_staffs` vs `staff_profiles` Overlap ✅ DECISION MADE

Both tables share columns: `email`, `fullname`, `grade`, `position`.

| Table            | Role                                                                        | Columns unique to it                                                   |
| ---------------- | --------------------------------------------------------------------------- | ---------------------------------------------------------------------- |
| `staff_profiles` | HR-enriched view. Imported read-only. Powers Staff Profile listing pages.   | `division`, `supervisor_name`, `employment_level`, `no_of_subordinate` |
| `ids_staffs`     | Assessment master data. Source of truth for KPI + psychometric assessments. | `staff_code`, `department_unit`                                        |

**Decision: Option B — Keep both with documented distinction.**

- Option A (rename `staff_profiles` → `ids_staffs`) would break all Phase 1 controllers, policies, views, and seeds. Not worth the risk.
- `staff_profiles` continues to serve the Staff Profile page (read-only import from IDS HR system).
- `ids_staffs` is the assessment anchor — every `kpi_assessment` and `psychometric_assessment` belongs to an `ids_staff`.
- **Governance rule**: When IDS system is updated, both tables are refreshed from the same import. No manual sync between them.

Add a cross-reference FK in Phase 2 if needed:

```ruby
add_reference :ids_staffs, :staff_profile, foreign_key: { to_table: :staff_profiles,
                                                            primary_key: :staff_profile_id },
              null: true
```

---

### 5. Score Column Data Types

All score columns (e.g. `proposal_preparation`, `total_score`) should use `decimal(5, 2)` to store values like `0.00` to `100.00` with precision. Avoid `float` due to floating-point rounding issues.

```ruby
# In migration:
t.decimal :proposal_preparation, precision: 5, scale: 2
```

---

### 6. `kpi_assessments` Typo

The original ERD image spells the table as `KpiAssestment` (missing 's'). Use the correct Rails convention: **`kpi_assessments`**.

---

### 7. `users.staff_profile_id` Missing from Current Schema

The target ERD shows `users.staff_profile_id` linking a user account to their staff profile. This column does not exist yet. A migration is needed before this relationship can be used:

```ruby
# Migration:
add_reference :users, :staff_profile, foreign_key: true, null: true
```

Note: FK column should be nullable since not every user account may have a matching staff profile.

---

### 8. `uploaded_pdf_file` — Use Active Storage

Instead of storing a file path string in `psychometric_assessments.uploaded_pdf_file`, use Rails **Active Storage**:

```ruby
class PsychometricAssessment < ApplicationRecord
  has_one_attached :uploaded_pdf_file
end
```

Benefits: cloud storage support (S3/GCS), built-in variant/preview, secure signed URLs, virus scanning hooks. Remove the string column from the migration and use Active Storage attachments instead.

---

## KPI Weight Strategy

> **Decision**: Hardcode weights as Ruby constants. Do **not** add weight columns to the database.

### Rationale

The scoring rubric weights (e.g. Report Writing = 30%, Research Work section = 70% of overall) are **fixed framework rules**, not per-record data. They do not vary by staff, quarter, or assessment instance. Storing them in the database adds unnecessary complexity with no current benefit.

The sub-score tables (`research_work_relateds`, `financial_managements`, etc.) store only the **actual scores entered by the assessor**. The final weighted total is computed at runtime using constants.

### When to reconsider

Migrate weights to a `kpi_rubrics` DB table **only if** any of the following become requirements:

- An admin needs to reconfigure the rubric (e.g. change 70% → 60% for a new year)
- Different grades/positions use different weightings
- Each saved assessment must record a snapshot of the weights in effect at submission time (audit trail)

### Constants (to be defined in `app/models/concerns/kpi_scoring.rb` or similar)

```ruby
# frozen_string_literal: true

module KpiScoring
  # Section weightage — contribution of each section to the overall quality KPI score
  SECTION_WEIGHTS = {
    research_work:        0.70,  # 70%
    financial_management: 0.10,  # 10%
    soft_skill:           0.10,  # 10%
    hard_skill:           0.05,  #  5%
    other_involvement:    0.05   #  5%
  }.freeze

  # Component max score per field — percentage scale (e.g. 10.0 means max 10%).
  # Use for: (1) numericality validation in sub-score models, (2) "Full Score (%)" display column.
  # NOTE: SECTION_WEIGHTS above are separate multipliers (fractions). These are NOT multipliers.
  RESEARCH_WORK_COMPONENTS = {
    proposal_preparation:     10.0,  # max 10%
    proposal_presentation:    10.0,  # max 10%
    data_collection:          10.0,  # max 10%
    data_entry_and_cleaning:  10.0,  # max 10%
    report_writing:           30.0,  # max 30%
    analysis_of_data:         15.0,  # max 15%
    presentation_of_findings: 15.0   # max 15%
  }.freeze                            # section max sum = 100.0

  FINANCIAL_MANAGEMENT_COMPONENTS = {
    budgeting:            25.0,  # max 25%
    record_keeping:       25.0,  # max 25%
    cashflow_management:  25.0,  # max 25%
    compliance:           25.0   # max 25%
  }.freeze                       # section max sum = 100.0

  SOFT_SKILL_COMPONENTS = {
    writing_skill:           20.0,  # max 20%
    presentation_skill:      20.0,  # max 20%
    computer_skill:          20.0,  # max 20%
    management_skill:        20.0,  # max 20%
    statistical_knowledge:   20.0   # max 20%
  }.freeze                           # section max sum = 100.0

  HARD_SKILL_COMPONENTS = {
    communication_skill:    20.0,  # max 20%
    collaboration_teamwork: 20.0,  # max 20%
    problem_solving:        20.0,  # max 20%
    leadership:             20.0,  # max 20%
    attention_details:      20.0   # max 20%
  }.freeze                          # section max sum = 100.0

  OTHER_INVOLVEMENT_COMPONENTS = {
    ideas_platform:            25.0,  # max 25%
    any_social_media_platform: 25.0,  # max 25%
    ids_watch_column:          25.0,  # max 25%
    others:                    25.0   # max 25%
  }.freeze                              # section max sum = 100.0

  # Quantity KPI — Output and Impact Based (100% of quantity score)
  OUTPUT_AND_IMPACT_COMPONENTS = {
    number_of_involvement:       20.0,  # max 20%
    output_production:           30.0,  # max 30%
    acceptance_of_outputs:       15.0,  # max 15%
    uptake_of_outputs:           10.0,  # max 10%
    presentation_state_level:    10.0,  # max 10%
    presentation_national_level: 15.0   # max 15%
  }.freeze                                # section max sum = 100.0
end
```

### Computed score example

```ruby
# Weighted quality KPI overall total (stored in quality_based_kpis.overall_total)
overall_total =
  (research_work.total_score  * KpiScoring::SECTION_WEIGHTS[:research_work]) +
  (financial.total_score      * KpiScoring::SECTION_WEIGHTS[:financial_management]) +
  (soft_skill.total_score     * KpiScoring::SECTION_WEIGHTS[:soft_skill]) +
  (hard_skill.total_score     * KpiScoring::SECTION_WEIGHTS[:hard_skill]) +
  (other_involvement.total_score * KpiScoring::SECTION_WEIGHTS[:other_involvement])
```

### DB columns affected

- `research_work_relateds.total_score` — stores the **raw section score** (sum of actual component scores, 0–100)
- `quality_based_kpis.overall_total` — stores the **final weighted total** (computed on save or in a service object)
- No weight columns are needed anywhere in the schema

---

_End of ERD documentation_
