# KPI Assessment — Complete Implementation Plan

> **Author**: ST Pilot IDS Team
> **Updated**: 2026-03-18
> **Audience**: Developers, QA, and stakeholders involved in KPI Assessment implementation

---

## Table of Contents

1. [Overview](#overview)
2. [Current State](#current-state)
3. [UI Flow (3-Level Navigation)](#ui-flow-3-level-navigation)
4. [Scoring Rules](#scoring-rules)
   - [Quality-Based KPI](#quality-based-kpi)
   - [Quantity-Based KPI](#quantity-based-kpi)
5. [How the Final Score is Calculated](#how-the-final-score-is-calculated)
6. [Weight Storage Decision](#weight-storage-decision)
7. [Complete Implementation Plan](#complete-implementation-plan)
   - [Step 1 — Migrations](#step-1--migrations)
   - [Step 2 — Models & Concern](#step-2--models--concern)
   - [Step 3 — Seeds](#step-3--seeds)
   - [Step 4 — Permissions](#step-4--permissions)
   - [Step 5 — Routes](#step-5--routes)
   - [Step 6 — Policy](#step-6--policy)
   - [Step 7 — Service Object (Score Calculator)](#step-7--service-object-score-calculator)
   - [Step 8 — Controller](#step-8--controller)
   - [Step 9 — Views](#step-9--views)
   - [Step 10 — Sidebar](#step-10--sidebar)
8. [File Change Summary](#file-change-summary)
9. [Data Flow Through Files](#data-flow-through-files)
10. [Ruby Constants Reference](#ruby-constants-reference)
11. [Worked Example](#worked-example)

---

## Overview

KPI Assessments in ST Pilot IDS use a **weighted scoring rubric**. Staff are assessed across two assessment types:

| Type                   | Description                                                           |
| ---------------------- | --------------------------------------------------------------------- |
| **Quality-Based KPI**  | Scores across 5 sections (A–E), each with a defined section weightage |
| **Quantity-Based KPI** | A single section (Output and Impact Based) worth 100%                 |

All weights are **fixed rules** — they do not vary per staff, per quarter, or per assessment. They are implemented as Ruby constants, not database columns.

---

## Current State

> As of 2026-03-18, the KPI Assessment module is a **stub**. The following files exist but contain no real logic:

| File                                            | Current State                                      |
| ----------------------------------------------- | -------------------------------------------------- |
| `app/controllers/kpi_assessments_controller.rb` | Only `index` action, just `authorize` call         |
| `app/policies/kpi_assessment_policy.rb`         | Only `index?` permission wired                     |
| `app/views/kpi_assessments/index.html.erb`      | "Module is under development" placeholder          |
| `config/routes.rb`                              | Only `resources :kpi_assessments, only: %i[index]` |
| `db/seeds/01_permissions.rb`                    | Only `kpi_assessments.index` seeded                |

**None of the planned database tables exist yet** (no `ids_staffs`, `quarters`, `kpi_assessments` table, sub-score tables, etc.).

---

## UI Flow (3-Level Navigation)

The KPI Assessment module has **three levels** of navigation:

### Level 1 — Year/Quarter Overview (`GET /kpi_assessments`)

```
┌────────────────────────────────────────────────────────────────────┐
│  KPI Assessment                         [+ Add KPI Assessment]     │
│                                                                    │
│  Year  │  Quarter                        │  Updated At             │
│  ──────┼─────────────────────────────────┼──────────────────────── │
│  2025  │ [Q1] [Q2] [Q3] [Q4]            │  11-03-2026, 3:00 PM    │
│  2024  │ [Q1] [Q2] [Q3] [Q4]            │  11-03-2026, 3:00 PM    │
└────────────────────────────────────────────────────────────────────┘
```

- Rows are grouped by `quarter.year` (newest year first).
- Each row shows 4 quarter buttons. Clicking a button drills down to Level 2.
- "Updated At" = latest `kpi_assessments.updated_at` for all assessments in that year.
- "Add KPI Assessment" button navigates to the wizard (Level 3 create flow).

### Level 2 — Quarter Staff Listing (`GET /kpi_assessments/quarter_staff?quarter_id=X`)

```
┌─────────────────────────────────────────────────────────────────┐
│  KPI Assessment > 2025 : Quarter 1                              │
│  ← Back to KPI Assessment                                      │
│                                                                 │
│  [ⓘ][✎][🗑] │ IDS Staff ID  │ Full Name      │ Reviewed At     │
│  ────────────┼───────────────┼────────────────┼──────────────── │
│  icons       │ STF_001       │ Ahmad Firdaus  │ 09-10-2024 3PM  │
│  icons       │ STF_002       │ Siti Aisyah    │ 09-10-2024 3PM  │
└─────────────────────────────────────────────────────────────────┘
```

- Lists all staff (IdsStaff records) that have a KpiAssessment for this quarter.
- Action icons: ⓘ → show, ✎ → edit, 🗑 → confirm delete modal.
- `Reviewed At` = `kpi_assessment.updated_at` for that staff + quarter.

### Level 3 — Individual Assessment Show (`GET /kpi_assessments/:id`)

```
┌────────────────────────────────────────────────────────────────────┐
│  KPI Assessment > 2025 : Quarter 1 > Ahmad Firdaus                 │
│  ← Back to 2025: Quarter 1                    [✎ Edit] [🗑 Delete] │
│                                                                    │
│  IDS Staff: Ahmad Firdaus         Position: Research Assistant     │
│  Select Quarter: Quarter 1                                         │
│                                                                    │
│  [ Quality-Based ]  Quantity-Based     Overall Total(%): 64.25/100 │
│                                                                    │
│  A. Research Work Related      ▲ (accordion, shows component scores│
│  B. Financial Management       ▲                                   │
│  C. Soft Skill                 ▲                                   │
│  D. Hard Skill                 ▼                                   │
│  E. Other Involvement          ▲                                   │
└────────────────────────────────────────────────────────────────────┘
```

- Full page view (not a modal). Breadcrumb links back to Level 2.
- Tabs toggle between Quality-Based and Quantity-Based sections.
- Edit button → `edit_kpi_assessment_path(@kpi_assessment)` (full-page edit form).
- Delete button → `confirm_delete_kpi_assessment_path(@kpi_assessment)` (Turbo Frame modal).

---

### Add KPI Assessment — 2-Step Wizard

Triggered by the "Add KPI Assessment" button on Level 1.

```
Step 1 of 2 — Quality-Based KPI  (GET /kpi_assessments/new)
┌─────────────────────────────────────────────────────────┐
│  KPI Assessment > Add KPI Assessment                    │
│  ← Back to KPI Assessment                              │
│                                                         │
│  IDS Staff: [dropdown ▼]    Position: [auto-filled]     │
│  Select Quarter: [dropdown ▼]                           │
│                                                         │
│  [ Quality-Based ]  Quantity-Based    Overall: --- /100 │
│                                                         │
│  A. Research Work Related          ▲ (collapsible)      │
│  B. Financial Management           ▲                    │
│  C. Soft Skill                     ▲                    │
│  D. Hard Skill                     ▼                    │
│  E. Other Involvement              ▲                    │
│                                                         │
│                                           [ Next → ]    │
└─────────────────────────────────────────────────────────┘
```

```
Step 2 of 2 — Quantity-Based KPI  (GET /kpi_assessments/:id/step2)
┌─────────────────────────────────────────────────────────┐
│  KPI Assessment > Add KPI Assessment                    │
│  ← Back to KPI Assessment                              │
│                                                         │
│  IDS Staff: [selected, read-only]  Position: [filled]   │
│  Select Quarter: [selected, read-only]                  │
│                                                         │
│  Quality-Based  [ Quantity-Based ]    Overall: --- /100 │
│                                                         │
│  Output and Impact Based           ▲                    │
│                                                         │
│  [ ← Previous ]                     [ Submit → ]        │
└─────────────────────────────────────────────────────────┘
```

**Behaviour Notes:**

- Selecting an IDS Staff auto-fills the Position field (Stimulus AJAX call to `position_for` endpoint).
- `Overall Total(%)` updates live as scores are entered (`kpi_score_controller.js`).
- Each section (A–E) is collapsible (Bootstrap accordion).
- On "Next →": validates + saves Quality-Based data → creates `KpiAssessment` + `QualityBasedKpi` records → redirects to `step2_kpi_assessment_path(@kpi_assessment)`.
- On "Submit →": saves `QuantityBasedKpi`, computes final score → redirects to **show page** (`kpi_assessment_path(@kpi_assessment)`).
- On edit (show page): `edit_kpi_assessment_path` renders a full-page edit form pre-filled with both Quality and Quantity scores, single Submit button updates both records.

---

## Scoring Rules

### Quality-Based KPI

#### Section Weights

These are the contributions of each section to the final Quality KPI overall total.

| Section | Name                  | Section Weight |
| ------- | --------------------- | -------------- |
| A       | Research Work Related | **70%**        |
| B       | Financial Management  | **10%**        |
| C       | Soft Skill            | **10%**        |
| D       | Hard Skill            | **5%**         |
| E       | Other Involvement     | **5%**         |
| —       | **Total**             | **100%**       |

> Each section has its own internal components. The assessor enters an actual score for each component. The section `total_score` is the sum of those component actual scores (out of 100). The final overall score applies the section weight on top.

---

#### Section A — Research Work Related

**Section weight: 70% of Quality KPI overall total**

| Component                | Full Score (%) |
| ------------------------ | -------------- |
| Proposal Preparation     | 10%            |
| Proposal Presentation    | 10%            |
| Data Collection          | 10%            |
| Data Entry and Cleaning  | 10%            |
| Report Writing           | 30%            |
| Analysis of Data         | 15%            |
| Presentation of Findings | 15%            |
| **Section Total**        | **100%**       |

---

#### Section B — Financial Management

**Section weight: 10% of Quality KPI overall total**

| Component            | Full Score (%) |
| -------------------- | -------------- |
| Budgeting            | 25%            |
| Record-Keeping       | 25%            |
| Cash-flow Management | 25%            |
| Compliance           | 25%            |
| **Section Total**    | **100%**       |

---

#### Section C — Soft Skill

**Section weight: 10% of Quality KPI overall total**

| Component             | Full Score (%) |
| --------------------- | -------------- |
| Writing Skill         | 20%            |
| Presentation Skill    | 20%            |
| Computer Skills       | 20%            |
| Management Skill      | 20%            |
| Statistical Knowledge | 20%            |
| **Section Total**     | **100%**       |

---

#### Section D — Hard Skill

**Section weight: 5% of Quality KPI overall total**

| Component                | Full Score (%) |
| ------------------------ | -------------- |
| Communication Skill      | 20%            |
| Collaboration & Teamwork | 20%            |
| Problem Solving          | 20%            |
| Leadership               | 20%            |
| Attention to Details     | 20%            |
| **Section Total**        | **100%**       |

---

#### Section E — Other Involvement

**Section weight: 5% of Quality KPI overall total**

| Component                  | Full Score (%) |
| -------------------------- | -------------- |
| IDEAS Platform             | 25%            |
| Any Social Media Platforms | 25%            |
| IDS Watch Column           | 25%            |
| Others                     | 25%            |
| **Section Total**          | **100%**       |

---

### Quantity-Based KPI

#### Output and Impact Based

**Section weight: 100% of Quantity KPI overall total**

| Component                     | Full Score (%) |
| ----------------------------- | -------------- |
| Number of Involvement         | 20%            |
| Output Production             | 30%            |
| Acceptance of Outputs         | 15%            |
| Uptake of Outputs             | 10%            |
| Presentation (State Level)    | 10%            |
| Presentation (National Level) | 15%            |
| **Section Total**             | **100%**       |

---

## How the Final Score is Calculated

### Quality-Based KPI

```
Step 1: For each section, sum the actual component scores entered by the assessor.
        This gives the raw section total_score (0–100).

Step 2: Multiply each section's total_score by its section weight.

Step 3: Sum all weighted section scores to get the overall_total.
```

$$
\text{overall\_total} =
  (\text{research\_work} \times 0.70) +
  (\text{financial\_management} \times 0.10) +
  (\text{soft\_skill} \times 0.10) +
  (\text{hard\_skill} \times 0.05) +
  (\text{other\_involvement} \times 0.05)
$$

### Quantity-Based KPI

```
Step 1: Sum the actual component scores.
        The section total_score IS the overall_total (no further weighting needed).
```

$$
\text{overall\_total} = \text{output\_and\_impact\_based.total\_score}
$$

---

## Weight Storage Decision

> **Weights are hardcoded as Ruby constants. No weight columns exist in the database.**

| What is stored in DB                | What is NOT stored in DB            |
| ----------------------------------- | ----------------------------------- |
| Actual scores entered per component | Component weights (e.g. 10%, 30%)   |
| Section `total_score` (0–100)       | Section weights (e.g. 70%, 10%)     |
| `overall_total` on the KPI record   | The rubric/scoring rules themselves |

**Why constants, not a database table?**

The rubric weights are fixed framework rules that apply identically to all staff, all quarters, and all assessment records. Putting them in a database column would add complexity without benefit.

**When to reconsider:**

Migrate to a `kpi_rubrics` table only if:

- An admin needs to change weights for a new year/period
- Different grades or positions use different weightings
- Each assessment must record a snapshot of the weights at the time of submission (audit trail)

---

## Complete Implementation Plan

### Step 1 — Migrations

Create all new tables. Run migrations **in this order** (respects FK dependencies):

#### 1a. `ids_staffs`

```bash
rails generate migration CreateIdsStaffs \
  staff_code:string:uniq email:string:uniq fullname:string grade:string department_unit:string position:string
```

```ruby
# db/migrate/YYYYMMDD_create_ids_staffs.rb
create_table :ids_staffs do |t|
  t.string :staff_code,     null: false   # External IDS identifier: "STF_001", "STF_002", etc.
  t.string :email,           null: false
  t.string :fullname,        null: false
  t.string :grade,           null: false
  t.string :department_unit, null: false
  t.string :position,        null: false
  t.timestamps
end
add_index :ids_staffs, :staff_code, unique: true
add_index :ids_staffs, :email,      unique: true
```

#### 1b. `quarters`

```bash
rails generate migration CreateQuarters quarter_name:string year:integer
```

```ruby
# db/migrate/YYYYMMDD_create_quarters.rb
create_table :quarters do |t|
  t.string  :quarter_name, null: false   # "Quarter 1", "Quarter 2", "Quarter 3", "Quarter 4"
  t.integer :year,         null: false   # 2024, 2025, 2026, ...
  t.timestamps
end
add_index :quarters, %i[quarter_name year], unique: true
```

> **Why a `year` column?** The index page groups assessments by year. With a dedicated `year` integer column, grouping is a simple `.group_by(&:year)` on Quarter. Without it, we'd need to parse `"Quarter 1 2025"` strings — fragile and slow.

#### 1c. `kpi_assessments`

> **Note**: Only store `ids_staff_id` + `quarter` context here. Do NOT copy fullname/grade/position — JOIN to `ids_staffs` instead. See ERD.md §3.

```bash
rails generate migration CreateKpiAssessments ids_staff:references
```

```ruby
# db/migrate/YYYYMMDD_create_kpi_assessments.rb
create_table :kpi_assessments do |t|
  t.references :ids_staff, null: false, foreign_key: true
  t.timestamps
end
```

#### 1d. Sub-score tables (quality)

```ruby
# research_work_relateds
create_table :research_work_relateds do |t|
  t.decimal :proposal_preparation,     precision: 5, scale: 2
  t.decimal :proposal_presentation,    precision: 5, scale: 2
  t.decimal :data_collection,          precision: 5, scale: 2
  t.decimal :data_entry_and_cleaning,  precision: 5, scale: 2
  t.decimal :report_writing,           precision: 5, scale: 2
  t.decimal :analysis_of_data,         precision: 5, scale: 2
  t.decimal :presentation_of_findings, precision: 5, scale: 2
  t.decimal :total_score,              precision: 5, scale: 2
  t.timestamps
end

# financial_managements
create_table :financial_managements do |t|
  t.decimal :budgeting,            precision: 5, scale: 2
  t.decimal :record_keeping,       precision: 5, scale: 2
  t.decimal :cashflow_management,  precision: 5, scale: 2
  t.decimal :compliance,           precision: 5, scale: 2
  t.decimal :total_score,          precision: 5, scale: 2
  t.timestamps
end

# soft_skills
create_table :soft_skills do |t|
  t.decimal :writing_skill,          precision: 5, scale: 2
  t.decimal :presentation_skill,     precision: 5, scale: 2
  t.decimal :computer_skill,         precision: 5, scale: 2
  t.decimal :management_skill,       precision: 5, scale: 2
  t.decimal :statistical_knowledge,  precision: 5, scale: 2
  t.decimal :total_score,            precision: 5, scale: 2
  t.timestamps
end

# hard_skills
create_table :hard_skills do |t|
  t.decimal :communication_skill,    precision: 5, scale: 2
  t.decimal :collaboration_teamwork, precision: 5, scale: 2
  t.decimal :problem_solving,        precision: 5, scale: 2
  t.decimal :leadership,             precision: 5, scale: 2
  t.decimal :attention_details,      precision: 5, scale: 2
  t.decimal :total_score,            precision: 5, scale: 2
  t.timestamps
end

# other_involvements
create_table :other_involvements do |t|
  t.decimal :ideas_platform,             precision: 5, scale: 2
  t.decimal :any_social_media_platform,  precision: 5, scale: 2
  t.decimal :ids_watch_column,           precision: 5, scale: 2
  t.decimal :others,                     precision: 5, scale: 2
  t.decimal :total_score,                precision: 5, scale: 2
  t.timestamps
end
```

#### 1e. `quality_based_kpis`

```ruby
create_table :quality_based_kpis do |t|
  t.references :kpi_assessment,      null: false, foreign_key: true
  t.references :quarter,             null: false, foreign_key: true
  t.decimal    :overall_total,       precision: 5, scale: 2
  t.references :research_work,       foreign_key: { to_table: :research_work_relateds }
  t.references :financial_management, foreign_key: { to_table: :financial_managements }
  t.references :soft_skill,          foreign_key: { to_table: :soft_skills }
  t.references :hard_skill,          foreign_key: { to_table: :hard_skills }
  t.references :other_involvement,   foreign_key: { to_table: :other_involvements }
  t.timestamps
end
add_index :quality_based_kpis, %i[kpi_assessment_id quarter_id], unique: true
```

#### 1f. Sub-score table (quantity)

```ruby
# output_and_impact_baseds
create_table :output_and_impact_baseds do |t|
  t.decimal :number_of_involvement,       precision: 5, scale: 2
  t.decimal :output_production,           precision: 5, scale: 2
  t.decimal :acceptance_of_outputs,       precision: 5, scale: 2
  t.decimal :uptake_of_outputs,           precision: 5, scale: 2
  t.decimal :presentation_state_level,    precision: 5, scale: 2
  t.decimal :presentation_national_level, precision: 5, scale: 2
  t.decimal :total_score,                 precision: 5, scale: 2
  t.timestamps
end
```

#### 1g. `quantity_based_kpis`

```ruby
create_table :quantity_based_kpis do |t|
  t.references :kpi_assessment,         null: false, foreign_key: true
  t.references :quarter,                null: false, foreign_key: true
  t.decimal    :overall_total,          precision: 5, scale: 2
  t.references :output_and_impact_based, foreign_key: { to_table: :output_and_impact_baseds }
  t.timestamps
end
add_index :quantity_based_kpis, %i[kpi_assessment_id quarter_id], unique: true
```

#### 1h. Add `staff_profile_id` to `users` (existing table)

```ruby
add_reference :users, :staff_profile, foreign_key: true, null: true
```

---

### Step 2 — Models & Concern

#### 2a. `app/models/concerns/kpi_scoring.rb` ← **NEW FILE**

Weight constants (see [Ruby Constants Reference](#ruby-constants-reference) below). This module is `include`-d into models that need to compute scores.

#### 2b. `app/models/ids_staff.rb` ← **NEW FILE**

```ruby
# frozen_string_literal: true

class IdsStaff < ApplicationRecord
  has_many :kpi_assessments,          dependent: :destroy
  has_many :psychometric_assessments, dependent: :destroy

  validates :staff_code, :email, :fullname, :grade, :department_unit, :position, presence: true
  validates :staff_code, uniqueness: true
  validates :email,      uniqueness: true

  def self.ransackable_attributes(_auth_object = nil)
    %w[id staff_code email fullname grade department_unit position created_at updated_at]
  end
end
```

#### 2c. `app/models/quarter.rb` ← **NEW FILE**

```ruby
# frozen_string_literal: true

class Quarter < ApplicationRecord
  has_many :quality_based_kpis, dependent: :destroy
  has_many :quantity_based_kpis, dependent: :destroy

  validates :quarter_name, presence: true
  validates :year, presence: true, numericality: { only_integer: true, greater_than: 2000 }
  validates :quarter_name, uniqueness: { scope: :year }

  def self.ransackable_attributes(_auth_object = nil)
    %w[id quarter_name year]
  end

  # Display helper: "2025 : Quarter 1"
  def display_name
    "#{year} : #{quarter_name}"
  end
end
```

#### 2d. `app/models/kpi_assessment.rb` ← **NEW FILE**

```ruby
# frozen_string_literal: true

class KpiAssessment < ApplicationRecord
  belongs_to :ids_staff

  has_many :quality_based_kpis,  dependent: :destroy
  has_many :quantity_based_kpis, dependent: :destroy
  has_many :quarters, through: :quality_based_kpis

  validates :ids_staff, presence: true
end
```

#### 2e. Sub-score models (quality) ← **NEW FILES**

Each follows this pattern (example: `research_work_related.rb`):

```ruby
# frozen_string_literal: true

class ResearchWorkRelated < ApplicationRecord
  include KpiScoring

  has_one :quality_based_kpi

  # Validate each component score is within its allowed maximum (percentage scale).
  # RESEARCH_WORK_COMPONENTS values are percentage max values (10.0, 30.0, etc.).
  RESEARCH_WORK_COMPONENTS.each do |component, max_score|
    validates component, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: max_score }
  end

  # Compute and cache the section total_score from individual component scores
  before_save :compute_total_score

  private

  def compute_total_score
    self.total_score = RESEARCH_WORK_COMPONENTS.keys.sum { |c| send(c).to_d }
  end
end
```

Create one model file for each sub-score table:

- `app/models/research_work_related.rb`
- `app/models/financial_management.rb`
- `app/models/soft_skill.rb`
- `app/models/hard_skill.rb`
- `app/models/other_involvement.rb`
- `app/models/output_and_impact_based.rb`

#### 2f. `app/models/quality_based_kpi.rb` ← **NEW FILE**

```ruby
# frozen_string_literal: true

class QualityBasedKpi < ApplicationRecord
  include KpiScoring

  belongs_to :kpi_assessment
  belongs_to :quarter
  belongs_to :research_work,        class_name: 'ResearchWorkRelated',  optional: true
  belongs_to :financial_management, class_name: 'FinancialManagement',  optional: true
  belongs_to :soft_skill,           class_name: 'SoftSkill',            optional: true
  belongs_to :hard_skill,           class_name: 'HardSkill',            optional: true
  belongs_to :other_involvement,    class_name: 'OtherInvolvement',     optional: true

  before_save :compute_overall_total

  private

  def compute_overall_total
    self.overall_total =
      (research_work&.total_score.to_d        * SECTION_WEIGHTS[:research_work]) +
      (financial_management&.total_score.to_d * SECTION_WEIGHTS[:financial_management]) +
      (soft_skill&.total_score.to_d           * SECTION_WEIGHTS[:soft_skill]) +
      (hard_skill&.total_score.to_d           * SECTION_WEIGHTS[:hard_skill]) +
      (other_involvement&.total_score.to_d    * SECTION_WEIGHTS[:other_involvement])
  end
end
```

#### 2g. `app/models/quantity_based_kpi.rb` ← **NEW FILE**

```ruby
# frozen_string_literal: true

class QuantityBasedKpi < ApplicationRecord
  belongs_to :kpi_assessment
  belongs_to :quarter
  belongs_to :output_and_impact_based, class_name: 'OutputAndImpactBased', optional: true

  before_save :compute_overall_total

  private

  def compute_overall_total
    self.overall_total = output_and_impact_based&.total_score.to_d
  end
end
```

---

### Step 3 — Seeds

#### `db/seeds/05_quarters.rb` ← **NEW FILE**

```ruby
# frozen_string_literal: true

puts 'Seeding quarters...'

# Quarter names match the UI display ("Quarter 1", "Quarter 2", etc.)
# Start from 2024 to match historical data in screenshots.
["Quarter 1", "Quarter 2", "Quarter 3", "Quarter 4"].each do |q|
  (2024..2030).each do |year|
    Quarter.find_or_create_by!(quarter_name: q, year: year)
  end
end

puts "  Created #{Quarter.count} quarters"
```

#### `db/seeds/06_ids_staffs.rb` ← **NEW FILE** (sample data)

```ruby
# frozen_string_literal: true

puts 'Seeding sample IDS staff...'

[
  { staff_code: 'STF_001', email: 'ahmad@ids.gov.my',  fullname: 'Ahmad bin Ali',   grade: 'S41', department_unit: 'Research', position: 'Research Officer' },
  { staff_code: 'STF_002', email: 'siti@ids.gov.my',   fullname: 'Siti binti Omar', grade: 'S44', department_unit: 'Finance',  position: 'Senior Officer' }
].each do |attrs|
  IdsStaff.find_or_create_by!(staff_code: attrs[:staff_code]) do |s|
    s.assign_attributes(attrs)
  end
end

puts "  Created #{IdsStaff.count} IDS staff records"
```

---

### Step 4 — Permissions

#### `db/seeds/01_permissions.rb` ← **MODIFY** (add new permission codes)

Add these permission codes:

```ruby
# KPI Assessment — full CRUD
{ code: 'kpi_assessments.index',   name: 'KPI Assessment - List' },
{ code: 'kpi_assessments.show',    name: 'KPI Assessment - View' },
{ code: 'kpi_assessments.create',  name: 'KPI Assessment - Create' },
{ code: 'kpi_assessments.update',  name: 'KPI Assessment - Edit' },
{ code: 'kpi_assessments.destroy', name: 'KPI Assessment - Delete' },
```

Also update `db/seeds/02_roles.rb` to grant `kpi_assessments.*` to the `staff` role as appropriate (typically `index` + `show` + `create` for staff; full CRUD for superadmin).

---

### Step 5 — Routes

#### `config/routes.rb` ← **MODIFY**

Replace the stub:

```ruby
# Before (stub):
resources :kpi_assessments, only: %i[index]

# After (full CRUD + wizard + quarter drill-down):
resources :kpi_assessments do
  member do
    get  :confirm_delete   # delete confirmation modal
    get  :step2            # Page 2 of wizard (quantity-based)
    post :save_step2       # Submit Page 2
  end
  collection do
    get :quarter_staff     # Level 2: staff list for a specific quarter
                           # usage: quarter_staff_kpi_assessments_path(quarter_id: id)
  end
  # Standard REST (new, create, show, edit, update, destroy) are included automatically
end
```

> **Note**: Do NOT add a `new_step1` collection route. Page 1 of the wizard is served by the
> standard `new` action (`GET /kpi_assessments/new`). Adding `new_step1` would conflict with
> the standard `new` helper and has no matching controller action.

Also add the IDS Staff AJAX endpoint (for auto-filling Position on staff select):

```ruby
namespace :master_data do
  resources :ids_staffs, only: %i[index] do
    collection do
      get :position_for  # returns position JSON for a given ids_staff_id
    end
  end
end
```

---

### Step 6 — Policy

#### `app/policies/kpi_assessment_policy.rb` ← **MODIFY**

```ruby
# frozen_string_literal: true

class KpiAssessmentPolicy < ApplicationPolicy
  # Permission codes:
  # kpi_assessments.index / .show / .create / .update / .destroy

  def show?    = user.has_permission?('kpi_assessments.show')
  def new?     = create?
  def create?  = user.has_permission?('kpi_assessments.create')
  def edit?    = update?
  def update?  = user.has_permission?('kpi_assessments.update')
  def destroy? = user.has_permission?('kpi_assessments.destroy')
  def confirm_delete? = destroy?
  def step2?   = create?
  def save_step2? = create?

  private

  def permission_resource = 'kpi_assessments'

  class Scope < ApplicationPolicy::Scope
    private
    def permission_resource = 'kpi_assessments'
  end
end
```

---

### Step 7 — Service Object (Score Calculator)

#### `app/services/kpi_score_calculator.rb` ← **NEW FILE**

Centralises all score computation logic, keeping models lean.

```ruby
# frozen_string_literal: true

class KpiScoreCalculator
  include KpiScoring

  # Computes and persists scores for a QualityBasedKpi record and all its sub-scores.
  def self.compute_quality(quality_kpi)
    new(quality_kpi).compute_quality
  end

  def self.compute_quantity(quantity_kpi)
    new(quantity_kpi).compute_quantity
  end

  def initialize(kpi_record)
    @kpi = kpi_record
  end

  def compute_quality
    %i[research_work financial_management soft_skill hard_skill other_involvement].each do |assoc|
      sub = @kpi.public_send(assoc)
      next unless sub

      components = const_get("#{assoc.to_s.upcase}_COMPONENTS")
      sub.total_score = components.keys.sum { |c| sub.public_send(c).to_d }
      sub.save!
    end

    @kpi.overall_total =
      (@kpi.research_work&.total_score.to_d        * SECTION_WEIGHTS[:research_work]) +
      (@kpi.financial_management&.total_score.to_d * SECTION_WEIGHTS[:financial_management]) +
      (@kpi.soft_skill&.total_score.to_d           * SECTION_WEIGHTS[:soft_skill]) +
      (@kpi.hard_skill&.total_score.to_d           * SECTION_WEIGHTS[:hard_skill]) +
      (@kpi.other_involvement&.total_score.to_d    * SECTION_WEIGHTS[:other_involvement])
    @kpi.save!
  end

  def compute_quantity
    oai = @kpi.output_and_impact_based
    return unless oai

    oai.total_score = OUTPUT_AND_IMPACT_COMPONENTS.keys.sum { |c| oai.public_send(c).to_d }
    oai.save!

    @kpi.overall_total = oai.total_score
    @kpi.save!
  end
end
```

---

### Step 8 — Controller

#### `app/controllers/kpi_assessments_controller.rb` ← **REWRITE**

```ruby
# frozen_string_literal: true

class KpiAssessmentsController < ApplicationController
  include RansackMultiSort

  before_action :set_kpi_assessment, only: %i[show edit update destroy confirm_delete step2 save_step2]

  # GET /kpi_assessments
  # Level 1: Year/Quarter grouped index
  def index
    authorize KpiAssessment

    # Group all defined quarters by year (newest year first).
    # The view renders one row per year with 4 quarter buttons.
    @quarters_by_year = Quarter.order(year: :desc, quarter_name: :asc).group_by(&:year)

    # Pre-compute latest updated_at per year for the "Updated At" column.
    @last_updated_by_year = KpiAssessment
      .joins(quality_based_kpis: :quarter)
      .group('quarters.year')
      .maximum(:updated_at)
  end

  # GET /kpi_assessments/quarter_staff?quarter_id=X
  # Level 2: Staff listing for a specific quarter
  def quarter_staff
    authorize KpiAssessment
    @quarter = Quarter.find(params[:quarter_id])

    apply_ransack_search(
      policy_scope(KpiAssessment)
        .joins(quality_based_kpis: :quarter)
        .where(quarters: { id: @quarter.id })
        .includes(:ids_staff)
        .order('ids_staffs.fullname')
    )
    @pagy, @kpi_assessments = paginate_results(@q.result)
  end

  # GET /kpi_assessments/:id
  # Level 3: Full-page assessment detail view (NOT a modal)
  def show
    authorize @kpi_assessment
    # Derive the quarter for the breadcrumb back-link
    @quality_kpi  = @kpi_assessment.quality_based_kpis.includes(:quarter, :research_work,
                     :financial_management, :soft_skill, :hard_skill, :other_involvement).first
    @quantity_kpi = @kpi_assessment.quantity_based_kpis.includes(:output_and_impact_based).first
    @quarter      = @quality_kpi&.quarter
  end

  # GET /kpi_assessments/new  (Page 1 — Quality-Based)
  def new
    @kpi_assessment = KpiAssessment.new
    @ids_staffs     = IdsStaff.order(:fullname)
    @quarters       = Quarter.order(year: :desc, quarter_name: :asc)
    authorize @kpi_assessment
  end

  # POST /kpi_assessments  (save Page 1, redirect to Page 2)
  # IMPORTANT: Form field naming must match these strong param keys.
  # Use `select_tag 'kpi_assessment[ids_staff_id]'` and
  # `select_tag 'quality_based_kpi[quarter_id]'` in the view — NOT f.select helpers
  # that auto-nest under :kpi_assessment.
  def create
    @kpi_assessment = KpiAssessment.new(kpi_assessment_params)
    authorize @kpi_assessment

    if @kpi_assessment.save
      build_quality_kpi(@kpi_assessment)
      redirect_to step2_kpi_assessment_path(@kpi_assessment),
                  notice: 'Quality scores saved. Please complete Quantity-Based KPI.'
    else
      @ids_staffs = IdsStaff.order(:fullname)
      @quarters   = Quarter.order(year: :desc, quarter_name: :asc)
      render :new, status: :unprocessable_entity
    end
  end

  # GET /kpi_assessments/:id/step2  (Page 2 — Quantity-Based)
  def step2
    authorize @kpi_assessment
    @quality_kpi  = @kpi_assessment.quality_based_kpis.includes(:quarter).first
    @quarter      = @quality_kpi&.quarter
    @quantity_kpi = @kpi_assessment.quantity_based_kpis.first_or_initialize
  end

  # POST /kpi_assessments/:id/save_step2  (final submit)
  # quarter_id is carried via hidden field `quantity_based_kpi[quarter_id]` in the form.
  # It is already covered by quantity_kpi_params — do NOT read params[:quarter_id] directly.
  def save_step2
    authorize @kpi_assessment

    @quantity_kpi = @kpi_assessment.quantity_based_kpis.first_or_initialize
    @quantity_kpi.assign_attributes(quantity_kpi_params)

    if @quantity_kpi.save
      KpiScoreCalculator.compute_quantity(@quantity_kpi)
      # Redirect to the show page so user immediately sees the completed assessment
      redirect_to kpi_assessment_path(@kpi_assessment),
                  notice: 'KPI Assessment submitted successfully.'
    else
      @quality_kpi = @kpi_assessment.quality_based_kpis.includes(:quarter).first
      @quarter     = @quality_kpi&.quarter
      render :step2, status: :unprocessable_entity
    end
  end

  # GET /kpi_assessments/:id/edit
  def edit
    authorize @kpi_assessment
    @ids_staffs   = IdsStaff.order(:fullname)
    @quarters     = Quarter.order(year: :desc, quarter_name: :asc)
    @quality_kpi  = @kpi_assessment.quality_based_kpis.includes(:quarter, :research_work,
                     :financial_management, :soft_skill, :hard_skill, :other_involvement).first
    @quantity_kpi = @kpi_assessment.quantity_based_kpis.includes(:output_and_impact_based).first
    @quarter      = @quality_kpi&.quarter
  end

  # PATCH/PUT /kpi_assessments/:id
  # Edit form uses the same field naming convention as create:
  # `kpi_assessment[ids_staff_id]` and `quality_based_kpi[...]` / `quantity_based_kpi[...]`.
  def update
    authorize @kpi_assessment

    quality_kpi  = @kpi_assessment.quality_based_kpis.first
    quantity_kpi = @kpi_assessment.quantity_based_kpis.first

    if quality_kpi&.update(quality_kpi_params) && quantity_kpi&.update(quantity_kpi_params)
      KpiScoreCalculator.compute_quality(quality_kpi)
      KpiScoreCalculator.compute_quantity(quantity_kpi)
      redirect_to kpi_assessment_path(@kpi_assessment), notice: 'KPI Assessment updated.'
    else
      @ids_staffs = IdsStaff.order(:fullname)
      @quarters   = Quarter.order(year: :desc, quarter_name: :asc)
      @quarter    = quality_kpi&.quarter
      render :edit, status: :unprocessable_entity
    end
  end

  # GET /kpi_assessments/:id/confirm_delete
  def confirm_delete
    authorize @kpi_assessment
    redirect_to kpi_assessments_path unless turbo_frame_request?
  end

  # DELETE /kpi_assessments/:id
  def destroy
    authorize @kpi_assessment
    @quarter = @kpi_assessment.quality_based_kpis.first&.quarter
    @kpi_assessment.destroy
    respond_to do |format|
      format.turbo_stream { flash.now[:notice] = 'KPI Assessment deleted.' }
      format.html do
        redirect_to (@quarter ? quarter_staff_kpi_assessments_path(quarter_id: @quarter.id)
                              : kpi_assessments_path),
                    notice: 'KPI Assessment deleted.'
      end
    end
  end

  private

  def set_kpi_assessment
    @kpi_assessment = KpiAssessment.find(params[:id])
  end

  def kpi_assessment_params
    params.require(:kpi_assessment).permit(:ids_staff_id)
  end

  # Used by create (build_quality_kpi) and update.
  # The view MUST submit quality fields under the key `quality_based_kpi[...]`,
  # NOT nested inside `kpi_assessment[...]`.
  def quality_kpi_params
    params.require(:quality_based_kpi).permit(
      :quarter_id,
      research_work_attributes:        %i[proposal_preparation proposal_presentation data_collection
                                          data_entry_and_cleaning report_writing analysis_of_data
                                          presentation_of_findings],
      financial_management_attributes: %i[budgeting record_keeping cashflow_management compliance],
      soft_skill_attributes:           %i[writing_skill presentation_skill computer_skill
                                          management_skill statistical_knowledge],
      hard_skill_attributes:           %i[communication_skill collaboration_teamwork problem_solving
                                          leadership attention_details],
      other_involvement_attributes:    %i[ideas_platform any_social_media_platform ids_watch_column others]
    )
  end

  # quarter_id MUST be submitted as a hidden field in the step2 / edit form:
  # `hidden_field_tag 'quantity_based_kpi[quarter_id]', @quarter&.id`
  # Do NOT read params[:quarter_id] directly outside of this method.
  def quantity_kpi_params
    params.require(:quantity_based_kpi).permit(
      :quarter_id,
      output_and_impact_based_attributes: %i[number_of_involvement output_production
                                             acceptance_of_outputs uptake_of_outputs
                                             presentation_state_level presentation_national_level]
    )
  end

  def build_quality_kpi(assessment)
    qkpi = assessment.quality_based_kpis.build(quality_kpi_params)
    qkpi.save
    KpiScoreCalculator.compute_quality(qkpi)
  end
end
```

---

### Step 9 — Views

#### Files to create:

```
app/views/kpi_assessments/
├── index.html.erb            ← Level 1: year/quarter grouped overview table
├── quarter_staff.html.erb    ← Level 2: staff listing for a specific quarter
├── show.html.erb             ← Level 3: full-page assessment detail (Quality + Quantity tabs)
├── new.html.erb              ← Page 1 wizard: Quality-Based form
├── step2.html.erb            ← Page 2 wizard: Quantity-Based form
├── edit.html.erb             ← Edit form (pre-filled Quality + Quantity, single submit)
├── confirm_delete.html.erb   ← Turbo Frame delete confirmation modal
└── _kpi_row.html.erb         ← quarter_staff table row partial (turbo_stream target)

app/views/kpi_assessments/
└── destroy.turbo_stream.erb  ← After delete: refresh table + flash message
```

#### Key view patterns:

**`new.html.erb`** — Page 1 (Quality-Based):

> **Critical — form field naming**: The form submits to two separate param roots:
>
> - `kpi_assessment[ids_staff_id]` → used by `kpi_assessment_params`
> - `quality_based_kpi[quarter_id]` and `quality_based_kpi[*_attributes][*]` → used by `quality_kpi_params`
>
> Use `form_with url: kpi_assessments_path` (no model binding) with `select_tag` helpers
> and explicit `name` attributes to keep the two param namespaces separate.

```erb
<%# app/views/kpi_assessments/new.html.erb %>
<%= form_with url: kpi_assessments_path do |f| %>
  <%# IDS Staff dropdown + auto-fill Position %>
  <%= select_tag 'kpi_assessment[ids_staff_id]',
        options_for_select(@ids_staffs.map { |s| [s.fullname, s.id] }),
        include_blank: 'Select IDS Staff',
        data: { controller: 'kpi-staff-select',
                action: 'change->kpi-staff-select#fetchPosition' } %>
  <input type="text" id="position-display" name="_position_display" readonly placeholder="Position">

  <%# Quarter dropdown — MUST be under quality_based_kpi[] namespace %>
  <%= select_tag 'quality_based_kpi[quarter_id]',
        options_for_select(@quarters.map { |q| [q.display_name, q.id] }),
        include_blank: 'Select Quarter' %>

  <%# Quality-Based sections A–E (Bootstrap accordion) %>
  <%# Each score field uses: quality_based_kpi[research_work_attributes][proposal_preparation] %>
  <%# ... accordion items with score inputs for each component ... %>

  <%= f.submit 'Next →', class: 'btn btn-success' %>
<% end %>
```

**`step2.html.erb`** — Page 2 (Quantity-Based):

```erb
<%# app/views/kpi_assessments/step2.html.erb %>
<%= form_with url: save_step2_kpi_assessment_path(@kpi_assessment), method: :post do |f| %>
  <%# Carry quarter_id into quantity_based_kpi params via hidden field %>
  <%= hidden_field_tag 'quantity_based_kpi[quarter_id]', @quarter&.id %>

  <%# Read-only display of selected staff and quarter %>
  <%# ... %>

  <%# Output and Impact Based section %>
  <%# Each score field: quantity_based_kpi[output_and_impact_based_attributes][number_of_involvement] %>

  <%= link_to '← Previous', new_kpi_assessment_path, class: 'btn btn-success' %>
  <%= f.submit 'Submit →', class: 'btn btn-success' %>
<% end %>
```

**`show.html.erb`** — Full-page detail view:

```erb
<%# app/views/kpi_assessments/show.html.erb %>
<%# Breadcrumb: KPI Assessment > 2025 : Quarter 1 > Ahmad Firdaus %>
<% if @quarter %>
  <%= link_to "← Back to #{@quarter.display_name}",
        quarter_staff_kpi_assessments_path(quarter_id: @quarter.id),
        class: 'btn btn-link' %>
<% end %>
<%= link_to '✎ Edit', edit_kpi_assessment_path(@kpi_assessment), class: 'btn btn-warning' %>
<%= link_to '🗑 Delete',
      confirm_delete_kpi_assessment_path(@kpi_assessment),
      data: { turbo_frame: 'modal' }, class: 'btn btn-danger' %>
<%# Quality + Quantity tabs, accordion sections ... %>
```

**`edit.html.erb`** — Full-page edit form (pre-filled):

```erb
<%# app/views/kpi_assessments/edit.html.erb %>
<%# Same field naming as new.html.erb but PATCH method and pre-filled values %>
<%= form_with url: kpi_assessment_path(@kpi_assessment), method: :patch do |f| %>
  <%# Pre-fill kpi_assessment[ids_staff_id], quality_based_kpi[...], quantity_based_kpi[...] %>
  <%# ... %>
  <%= f.submit 'Save Changes', class: 'btn btn-primary' %>
<% end %>
```

#### JavaScript — `app/javascript/controllers/kpi_staff_select_controller.js` ← **NEW FILE**

Fetches and fills the Position field when a staff is selected:

```javascript
// app/javascript/controllers/kpi_staff_select_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  fetchPosition(event) {
    const staffId = event.target.value;
    if (!staffId) {
      document.getElementById("position-display").value = "";
      return;
    }

    fetch(`/master_data/ids_staffs/position_for?ids_staff_id=${staffId}`, {
      headers: { Accept: "application/json" },
    })
      .then((r) => r.json())
      .then((data) => {
        document.getElementById("position-display").value = data.position || "";
      });
  }
}
```

Also add a `kpi_score_controller.js` ← **NEW FILE** for live overall total computation as scores are entered.

---

### Step 10 — Sidebar

#### `app/views/layouts/dashboard/_sidebar.html.erb` ← **MODIFY**

The KPI Assessment sidebar link is already wired via `can_view_menu?("kpi_assessments.index")`. No change needed to the guard. However, update the link to point to `new_kpi_assessment_path` for an "Add" button if desired:

```erb
<%# Already exists — verify this is present: %>
<% if can_view_menu?("kpi_assessments.index") %>
  <%= link_to kpi_assessments_path, class: "nav-link ..." do %>
    KPI Assessment
  <% end %>
<% end %>
```

---

## File Change Summary

| #   | File                                                        | Action      | Notes                                   |
| --- | ----------------------------------------------------------- | ----------- | --------------------------------------- |
| 1   | `db/migrate/*_create_ids_staffs.rb`                         | **CREATE**  | New table                               |
| 2   | `db/migrate/*_create_quarters.rb`                           | **CREATE**  | New table (quarter_name + year)         |
| 3   | `db/migrate/*_create_kpi_assessments.rb`                    | **CREATE**  | New table                               |
| 4   | `db/migrate/*_create_research_work_relateds.rb`             | **CREATE**  | Sub-score                               |
| 5   | `db/migrate/*_create_financial_managements.rb`              | **CREATE**  | Sub-score                               |
| 6   | `db/migrate/*_create_soft_skills.rb`                        | **CREATE**  | Sub-score                               |
| 7   | `db/migrate/*_create_hard_skills.rb`                        | **CREATE**  | Sub-score                               |
| 8   | `db/migrate/*_create_other_involvements.rb`                 | **CREATE**  | Sub-score                               |
| 9   | `db/migrate/*_create_quality_based_kpis.rb`                 | **CREATE**  | Quality pivot                           |
| 10  | `db/migrate/*_create_output_and_impact_baseds.rb`           | **CREATE**  | Sub-score                               |
| 11  | `db/migrate/*_create_quantity_based_kpis.rb`                | **CREATE**  | Quantity pivot                          |
| 12  | `db/migrate/*_add_staff_profile_id_to_users.rb`             | **CREATE**  | FK to staff_profiles                    |
| 13  | `app/models/concerns/kpi_scoring.rb`                        | **CREATE**  | Weight constants                        |
| 14  | `app/models/ids_staff.rb`                                   | **CREATE**  | New model                               |
| 15  | `app/models/quarter.rb`                                     | **CREATE**  | New model                               |
| 16  | `app/models/kpi_assessment.rb`                              | **CREATE**  | New model (replaces nil)                |
| 17  | `app/models/research_work_related.rb`                       | **CREATE**  | Sub-score model                         |
| 18  | `app/models/financial_management.rb`                        | **CREATE**  | Sub-score model                         |
| 19  | `app/models/soft_skill.rb`                                  | **CREATE**  | Sub-score model                         |
| 20  | `app/models/hard_skill.rb`                                  | **CREATE**  | Sub-score model                         |
| 21  | `app/models/other_involvement.rb`                           | **CREATE**  | Sub-score model                         |
| 22  | `app/models/output_and_impact_based.rb`                     | **CREATE**  | Sub-score model                         |
| 23  | `app/models/quality_based_kpi.rb`                           | **CREATE**  | Quality pivot model                     |
| 24  | `app/models/quantity_based_kpi.rb`                          | **CREATE**  | Quantity pivot model                    |
| 25  | `app/services/kpi_score_calculator.rb`                      | **CREATE**  | Score computation                       |
| 26  | `db/seeds/01_permissions.rb`                                | **MODIFY**  | Add create/update/destroy/show          |
| 27  | `db/seeds/02_roles.rb`                                      | **MODIFY**  | Assign new permissions to roles         |
| 28  | `db/seeds/05_quarters.rb`                                   | **CREATE**  | Q1–Q4 2025–2030                         |
| 29  | `db/seeds/06_ids_staffs.rb`                                 | **CREATE**  | Sample staff data                       |
| 30  | `config/routes.rb`                                          | **MODIFY**  | Full CRUD + wizard + quarter drill-down |
| 31  | `app/policies/kpi_assessment_policy.rb`                     | **MODIFY**  | Add all CRUD policy methods             |
| 32  | `app/controllers/kpi_assessments_controller.rb`             | **REWRITE** | Full CRUD + wizard + quarter_staff      |
| 33  | `app/controllers/master_data/ids_staffs_controller.rb`      | **MODIFY**  | Add `position_for` action               |
| 34  | `app/views/kpi_assessments/index.html.erb`                  | **REWRITE** | Year/quarter grouped overview           |
| 35  | `app/views/kpi_assessments/quarter_staff.html.erb`          | **CREATE**  | Level 2: staff list for one quarter     |
| 36  | `app/views/kpi_assessments/new.html.erb`                    | **CREATE**  | Page 1 wizard form (Quality-Based)      |
| 37  | `app/views/kpi_assessments/step2.html.erb`                  | **CREATE**  | Page 2 wizard form (Quantity-Based)     |
| 38  | `app/views/kpi_assessments/show.html.erb`                   | **CREATE**  | Full-page detail view                   |
| 39  | `app/views/kpi_assessments/edit.html.erb`                   | **CREATE**  | Full-page edit form                     |
| 40  | `app/views/kpi_assessments/confirm_delete.html.erb`         | **CREATE**  | Turbo Frame delete modal                |
| 41  | `app/views/kpi_assessments/_kpi_row.html.erb`               | **CREATE**  | quarter_staff table row partial         |
| 42  | `app/views/kpi_assessments/destroy.turbo_stream.erb`        | **CREATE**  | Turbo stream delete                     |
| 43  | `app/javascript/controllers/kpi_staff_select_controller.js` | **CREATE**  | Position auto-fill                      |
| 44  | `app/javascript/controllers/kpi_score_controller.js`        | **CREATE**  | Live score calculation                  |

---

## Data Flow Through Files

```
BROWSER REQUEST: User fills Page 1 (Quality-Based) and clicks "Next →"
│
│  POST /kpi_assessments
│
▼
config/routes.rb
  └── resources :kpi_assessments → KpiAssessmentsController#create
      │
      ▼
  app/controllers/kpi_assessments_controller.rb  #create
      │  1. authorize @kpi_assessment
      │     └── app/policies/kpi_assessment_policy.rb  #create?
      │         └── user.has_permission?('kpi_assessments.create')
      │             └── app/models/user.rb  #has_permission?
      │
      │  2. KpiAssessment.new(kpi_assessment_params)
      │     └── app/models/kpi_assessment.rb
      │         └── belongs_to :ids_staff → app/models/ids_staff.rb
      │
      │  3. @kpi_assessment.save
      │
      │  4. build_quality_kpi(@kpi_assessment)
      │     └── QualityBasedKpi.new(quality_kpi_params)
      │         └── app/models/quality_based_kpi.rb
      │             └── nested: ResearchWorkRelated, FinancialManagement,
      │                         SoftSkill, HardSkill, OtherInvolvement
      │
      │  5. KpiScoreCalculator.compute_quality(qkpi)
      │     └── app/services/kpi_score_calculator.rb
      │         ├── include KpiScoring (constants from app/models/concerns/kpi_scoring.rb)
      │         ├── for each sub-score: computes total_score using COMPONENT constants
      │         └── computes overall_total using SECTION_WEIGHTS constants
      │
      └── redirect_to step2_kpi_assessment_path(@kpi_assessment)


BROWSER REQUEST: User fills Page 2 (Quantity-Based) and clicks "Submit →"
│
│  POST /kpi_assessments/:id/save_step2
│
▼
config/routes.rb
  └── member :save_step2 → KpiAssessmentsController#save_step2
      │
      ▼
  app/controllers/kpi_assessments_controller.rb  #save_step2
      │  1. authorize @kpi_assessment (kpi_assessment_policy.rb)
      │
      │  2. QuantityBasedKpi.new / assign_attributes(quantity_kpi_params)
      │     └── app/models/quantity_based_kpi.rb
      │         └── nested: OutputAndImpactBased
      │
      │  3. @quantity_kpi.save
      │
      │  4. KpiScoreCalculator.compute_quantity(@quantity_kpi)
      │     └── app/services/kpi_score_calculator.rb
      │         ├── include KpiScoring
      │         └── computes output_and_impact_based.total_score
      │             (= overall_total, since weight is 100%)
      │
      └── redirect_to kpi_assessments_path


BROWSER REQUEST: GET /kpi_assessments (index listing)
│
▼
config/routes.rb → KpiAssessmentsController#index
    │  1. authorize KpiAssessment (policy: index?)
    │  2. @quarters_by_year = Quarter.order(year: :desc).group_by(&:year)
    │  3. @last_updated_by_year = KpiAssessment.joins(...).group('quarters.year').maximum(:updated_at)
    │
    └── render app/views/kpi_assessments/index.html.erb
            └── renders year/quarter grouped table with [Quarter 1]..[Quarter 4] buttons


BROWSER REQUEST: GET /kpi_assessments/quarter_staff?quarter_id=X
│
▼
config/routes.rb → KpiAssessmentsController#quarter_staff
    │  1. authorize KpiAssessment (policy: index?)
    │  2. @quarter = Quarter.find(params[:quarter_id])
    │  3. apply_ransack_search(policy_scope(KpiAssessment).joins(quality_based_kpis: :quarter)
    │                           .where(quarters: { id: @quarter.id }))
    │  4. paginate_results(@q.result)
    │
    └── render app/views/kpi_assessments/quarter_staff.html.erb
            └── renders staff table with [ⓘ][✎][🗑] action icons per row


JAVASCRIPT: User selects an IDS Staff in the dropdown
│
▼
app/javascript/controllers/kpi_staff_select_controller.js
    └── fetch GET /master_data/ids_staffs/position_for?ids_staff_id=X
        │
        ▼
    app/controllers/master_data/ids_staffs_controller.rb  #position_for
        └── IdsStaff.find(params[:ids_staff_id])
            └── render json: { position: ids_staff.position }
        │
        ▼
    kpi_staff_select_controller.js fills #position-display input


JAVASCRIPT: User enters a score value
│
▼
app/javascript/controllers/kpi_score_controller.js
    └── reads all input values for the section
        computes section total and overall total in real-time
        updates "Overall Total(%)" display element
```

---

## Ruby Constants Reference

`app/models/concerns/kpi_scoring.rb`:

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
    writing_skill:          20.0,  # max 20%
    presentation_skill:     20.0,  # max 20%
    computer_skill:         20.0,  # max 20%
    management_skill:       20.0,  # max 20%
    statistical_knowledge:  20.0   # max 20%
  }.freeze                          # section max sum = 100.0

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

---

## Worked Example

**Staff**: Ahmad bin Ali
**Quarter**: Q1 2026
**Assessment type**: Quality-Based KPI

### Step 1 — Section scores entered by assessor

| Section                 | Actual Scores Entered                                                                                                 | Section total_score |
| ----------------------- | --------------------------------------------------------------------------------------------------------------------- | ------------------- |
| A. Research Work        | Proposal Prep: 8, Proposal Pres: 7, Data Coll: 9, Data Entry: 8, Report Writing: 25, Analysis: 12, Pres. Findings: 13 | **82**              |
| B. Financial Management | Budgeting: 20, Record-keeping: 18, Cashflow: 22, Compliance: 20                                                       | **80**              |
| C. Soft Skill           | Writing: 18, Presentation: 16, Computer: 20, Management: 17, Statistical: 15                                          | **86**              |
| D. Hard Skill           | Communication: 18, Collaboration: 17, Problem Solving: 16, Leadership: 15, Attention: 19                              | **85**              |
| E. Other Involvement    | IDEAS: 20, Social Media: 15, Watch Column: 18, Others: 10                                                             | **63**              |

### Step 2 — Apply section weights

| Section           | total_score | Weight | Weighted Score |
| ----------------- | ----------- | ------ | -------------- |
| A. Research Work  | 82          | × 0.70 | **57.40**      |
| B. Financial Mgmt | 80          | × 0.10 | **8.00**       |
| C. Soft Skill     | 86          | × 0.10 | **8.60**       |
| D. Hard Skill     | 85          | × 0.05 | **4.25**       |
| E. Other Involve. | 63          | × 0.05 | **3.15**       |

### Step 3 — Final overall total

$$
\text{overall\_total} = 57.40 + 8.00 + 8.60 + 4.25 + 3.15 = \mathbf{81.40 / 100}
$$

This value (`81.40`) is stored in `quality_based_kpis.overall_total`.

---

_Document maintained in `docs/KPI_WEIGHT_STRATEGY.md`. For schema details, see [ERD.md](ERD.md)._

---

## Quality-Based KPI

### Section Weights

These are the contributions of each section to the final Quality KPI overall total.

| Section | Name                  | Section Weight |
| ------- | --------------------- | -------------- |
| A       | Research Work Related | **70%**        |
| B       | Financial Management  | **10%**        |
| C       | Soft Skill            | **10%**        |
| D       | Hard Skill            | **5%**         |
| E       | Other Involvement     | **5%**         |
| —       | **Total**             | **100%**       |

> Each section has its own internal components. The assessor enters an actual score for each component. The section `total_score` is the sum of those component actual scores (out of 100). The final overall score applies the section weight on top.

---

### Section A — Research Work Related

**Section weight: 70% of Quality KPI overall total**

| Component                | Full Score (%) |
| ------------------------ | -------------- |
| Proposal Preparation     | 10%            |
| Proposal Presentation    | 10%            |
| Data Collection          | 10%            |
| Data Entry and Cleaning  | 10%            |
| Report Writing           | 30%            |
| Analysis of Data         | 15%            |
| Presentation of Findings | 15%            |
| **Section Total**        | **100%**       |

---

### Section B — Financial Management

**Section weight: 10% of Quality KPI overall total**

| Component            | Full Score (%) |
| -------------------- | -------------- |
| Budgeting            | 25%            |
| Record-Keeping       | 25%            |
| Cash-flow Management | 25%            |
| Compliance           | 25%            |
| **Section Total**    | **100%**       |

---

### Section C — Soft Skill

**Section weight: 10% of Quality KPI overall total**

| Component             | Full Score (%) |
| --------------------- | -------------- |
| Writing Skill         | 20%            |
| Presentation Skill    | 20%            |
| Computer Skills       | 20%            |
| Management Skill      | 20%            |
| Statistical Knowledge | 20%            |
| **Section Total**     | **100%**       |

---

### Section D — Hard Skill

**Section weight: 5% of Quality KPI overall total**

| Component                | Full Score (%) |
| ------------------------ | -------------- |
| Communication Skill      | 20%            |
| Collaboration & Teamwork | 20%            |
| Problem Solving          | 20%            |
| Leadership               | 20%            |
| Attention to Details     | 20%            |
| **Section Total**        | **100%**       |

---

### Section E — Other Involvement

**Section weight: 5% of Quality KPI overall total**

| Component                  | Full Score (%) |
| -------------------------- | -------------- |
| IDEAS Platform             | 25%            |
| Any Social Media Platforms | 25%            |
| IDS Watch Column           | 25%            |
| Others                     | 25%            |
| **Section Total**          | **100%**       |

---

## Quantity-Based KPI

### Output and Impact Based

**Section weight: 100% of Quantity KPI overall total**

| Component                     | Full Score (%) |
| ----------------------------- | -------------- |
| Number of Involvement         | 20%            |
| Output Production             | 30%            |
| Acceptance of Outputs         | 15%            |
| Uptake of Outputs             | 10%            |
| Presentation (State Level)    | 10%            |
| Presentation (National Level) | 15%            |
| **Section Total**             | **100%**       |

---

## How the Final Score is Calculated

### Quality-Based KPI

```
Step 1: For each section, sum the actual component scores entered by the assessor.
        This gives the raw section total_score (0–100).

Step 2: Multiply each section's total_score by its section weight.

Step 3: Sum all weighted section scores to get the overall_total.
```

**Formula:**

$$
\text{overall\_total} =
  (\text{research\_work} \times 0.70) +
  (\text{financial\_management} \times 0.10) +
  (\text{soft\_skill} \times 0.10) +
  (\text{hard\_skill} \times 0.05) +
  (\text{other\_involvement} \times 0.05)
$$

### Quantity-Based KPI

```
Step 1: Sum the actual component scores.
        The section total_score IS the overall_total (no further weighting needed).
```

$$
\text{overall\_total} = \text{output\_and\_impact\_based.total\_score}
$$

---

## Storage Decision

> **Weights are hardcoded as Ruby constants. No weight columns exist in the database.**

| What is stored in DB                | What is NOT stored in DB            |
| ----------------------------------- | ----------------------------------- |
| Actual scores entered per component | Component weights (e.g. 10%, 30%)   |
| Section `total_score` (0–100)       | Section weights (e.g. 70%, 10%)     |
| `overall_total` on the KPI record   | The rubric/scoring rules themselves |

**Why constants, not a database table?**

The rubric weights are fixed framework rules that apply identically to all staff, all quarters, and all assessment records. Putting them in a database column would add complexity without benefit.

**When to reconsider:**

Migrate to a `kpi_rubrics` table only if:

- An admin needs to change weights for a new year/period
- Different grades or positions use different weightings
- Each assessment must record a snapshot of the weights at the time of submission (audit trail)

---

## Ruby Constants Reference

Defined in `app/models/concerns/kpi_scoring.rb`:

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
    writing_skill:          20.0,  # max 20%
    presentation_skill:     20.0,  # max 20%
    computer_skill:         20.0,  # max 20%
    management_skill:       20.0,  # max 20%
    statistical_knowledge:  20.0   # max 20%
  }.freeze                          # section max sum = 100.0

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

**Usage in a model or service object:**

```ruby
# Compute quality KPI overall total
overall_total =
  (research_work.total_score     * KpiScoring::SECTION_WEIGHTS[:research_work]) +
  (financial.total_score         * KpiScoring::SECTION_WEIGHTS[:financial_management]) +
  (soft_skill.total_score        * KpiScoring::SECTION_WEIGHTS[:soft_skill]) +
  (hard_skill.total_score        * KpiScoring::SECTION_WEIGHTS[:hard_skill]) +
  (other_involvement.total_score * KpiScoring::SECTION_WEIGHTS[:other_involvement])
```

---

## Worked Example

**Staff**: Ahmad bin Ali
**Quarter**: Q1 2026
**Assessment type**: Quality-Based KPI

### Step 1 — Section scores entered by assessor

| Section                 | Actual Scores Entered                                                                                                 | Section total_score |
| ----------------------- | --------------------------------------------------------------------------------------------------------------------- | ------------------- |
| A. Research Work        | Proposal Prep: 8, Proposal Pres: 7, Data Coll: 9, Data Entry: 8, Report Writing: 25, Analysis: 12, Pres. Findings: 13 | **82**              |
| B. Financial Management | Budgeting: 20, Record-keeping: 18, Cashflow: 22, Compliance: 20                                                       | **80**              |
| C. Soft Skill           | Writing: 18, Presentation: 16, Computer: 20, Management: 17, Statistical: 15                                          | **86**              |
| D. Hard Skill           | Communication: 18, Collaboration: 17, Problem Solving: 16, Leadership: 15, Attention: 19                              | **85**              |
| E. Other Involvement    | IDEAS: 20, Social Media: 15, Watch Column: 18, Others: 10                                                             | **63**              |

### Step 2 — Apply section weights

| Section           | total_score | Weight | Weighted Score |
| ----------------- | ----------- | ------ | -------------- |
| A. Research Work  | 82          | × 0.70 | **57.40**      |
| B. Financial Mgmt | 80          | × 0.10 | **8.00**       |
| C. Soft Skill     | 86          | × 0.10 | **8.60**       |
| D. Hard Skill     | 85          | × 0.05 | **4.25**       |
| E. Other Involve. | 63          | × 0.05 | **3.15**       |

### Step 3 — Final overall total

$$
\text{overall\_total} = 57.40 + 8.00 + 8.60 + 4.25 + 3.15 = \mathbf{81.40 / 100}
$$

This value (`81.40`) is stored in `quality_based_kpis.overall_total`.

---

_Document maintained in `docs/KPI_WEIGHT_STRATEGY.md`. For schema details, see [ERD.md](ERD.md)._
