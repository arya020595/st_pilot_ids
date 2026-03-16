# AGENTS.md — AI Agent Guide for ST Pilot IDS

> **Purpose**: This file provides AI coding agents (GitHub Copilot, Cursor, Cody, etc.) with full project context to understand the architecture, codebase, conventions, and workflows at a glance.

---

## 1. Project Identity

| Field          | Value                                                      |
| -------------- | ---------------------------------------------------------- |
| **Name**       | ST Pilot IDS                                               |
| **Type**       | Internal Staff Profile & Assessment Management System      |
| **Framework**  | Ruby on Rails 8.1                                          |
| **Database**   | PostgreSQL (via `pg` gem)                                  |
| **Frontend**   | Hotwire (Turbo + Stimulus), Bootstrap 5.3, importmap-rails |
| **Auth**       | Devise (authentication) + Pundit (authorization)           |
| **Deployment** | Docker                                                     |

---

## 2. What This App Does

ST Pilot IDS is an internal staff intelligence and assessment platform where:

1. **Superadmin** manages users, roles, and permissions
2. **Staff users** can view their profiles, BI dashboards, KPI assessments and psychometric assessments
3. Access control is entirely permission-based via roles

### Core Business Flow

```
User ──belongs_to──→ Role ──has_many──→ Permission
StaffProfile (imported from IDS, read-only listing)
```

---

## 3. Directory Structure (Key Files)

```
st_pilot_ids/
├── app/
│   ├── controllers/
│   │   ├── application_controller.rb              # Base: auth, Pundit, Pagy, layout
│   │   ├── dashboard_controller.rb                # Home page
│   │   ├── staff_profiles_controller.rb           # Staff profile listing + show (modal)
│   │   ├── bi_dashboards_controller.rb            # BI Dashboard stub
│   │   ├── psychometric_assessments_controller.rb # Psychometric Assessment stub
│   │   ├── kpi_assessments_controller.rb          # KPI Assessment stub
│   │   ├── concerns/
│   │   │   └── ransack_multi_sort.rb              # Ransack + Pagy helper concern
│   │   ├── master_data/
│   │   │   └── ids_staffs_controller.rb           # IDS Staff listing under Master Data
│   │   ├── user_management/
│   │   │   ├── users_controller.rb                # Full CRUD for users
│   │   │   └── roles_controller.rb                # Full CRUD for roles + permissions
│   │   └── users/
│   │       ├── sessions_controller.rb             # Custom Devise sessions
│   │       └── registrations_controller.rb        # Custom Devise registrations
│   │
│   ├── models/
│   │   ├── user.rb                                # Devise + permission_codes caching
│   │   ├── role.rb                                # has_many :permissions through :role_permissions
│   │   ├── permission.rb                          # code format: "namespace.resource.action"
│   │   ├── role_permission.rb                     # Join table
│   │   ├── staff_profile.rb                       # Read-only staff profile (custom primary key: staff_profile_id)
│   │   └── current.rb                             # CurrentAttributes (Current.user)
│   │
│   ├── policies/
│   │   ├── application_policy.rb                  # Base: auto-builds permission codes
│   │   ├── dashboard_policy.rb                    # resource: "dashboard"
│   │   ├── staff_profile_policy.rb                # resource: "staff_profiles"
│   │   ├── bi_dashboard_policy.rb                 # resource: "bi_dashboards"
│   │   ├── psychometric_assessment_policy.rb      # resource: "psychometric_assessments"
│   │   ├── kpi_assessment_policy.rb               # resource: "kpi_assessments"
│   │   ├── master_data/
│   │   │   └── ids_staff_policy.rb                # resource: "master_data.ids_staffs"
│   │   └── user_management/
│   │       ├── user_policy.rb                     # resource: "user_management.users"
│   │       └── role_policy.rb                     # resource: "user_management.roles"
│   │
│   ├── helpers/
│   │   └── application_helper.rb                  # can_view_menu?, modal_link_data, per_page_selector
│   │
│   ├── javascript/
│   │   ├── application.js                         # Entry: Turbo, Bootstrap, Stimulus controllers
│   │   └── controllers/
│   │       ├── flash_controller.js                # Flash message auto-dismiss
│   │       ├── modal_controller.js                # Bootstrap modal + Turbo Frame lifecycle
│   │       ├── search_form_controller.js          # Auto-submit search with debounce
│   │       └── sidebar_controller.js              # Sidebar toggle + mobile collapse
│   │
│   └── views/
│       ├── layouts/
│       │   ├── dashboard/application.html.erb     # Authenticated layout (navbar + sidebar + main)
│       │   └── application.html.erb               # Public layout (Devise pages)
│       ├── staff_profiles/                        # Index + show (modal)
│       ├── bi_dashboards/                         # Index (stub)
│       ├── psychometric_assessments/              # Index (stub)
│       ├── kpi_assessments/                       # Index (stub)
│       ├── dashboard/                             # Root home page
│       ├── master_data/ids_staffs/               # Index listing
│       ├── user_management/                       # Users and Roles CRUD
│       ├── devise/                                # Login pages
│       └── shared/                                # Reusable partials
│
├── config/
│   ├── routes.rb                                  # All route definitions
│   ├── importmap.rb                               # JS module pins (Bootstrap CDN)
│   └── initializers/                              # Devise, Pundit, Pagy, etc.
│
└── db/
    ├── schema.rb                                  # Current schema
    ├── seeds.rb                                   # Permissions, roles, users, staff profiles
    └── migrate/                                   # Migration files
```

---

## 4. Data Model & Relationships

### Schema Overview

```
permissions        code (unique), name
role_permissions   role_id, permission_id (join table)
roles              name (unique)
users              email, name, role_id, is_active, (Devise fields)
staff_profiles     staff_profile_id (PK), fullname, email, grade, position, division, supervisor_name, employment_level, no_of_subordinate
```

### Key Associations

```ruby
User         belongs_to :role (optional)
Role         has_many :role_permissions
             has_many :permissions, through: :role_permissions
Permission   has_many :role_permissions
             has_many :roles, through: :role_permissions
RolePermission belongs_to :role; belongs_to :permission
StaffProfile  # No associations — standalone read-only model (custom PK: staff_profile_id)
```

---

## 5. Permission System

### Permission Code Format

```
{namespace.}{resource}.{action}

Examples:
  dashboard.index
  bi_dashboards.index
  staff_profiles.index / staff_profiles.show
  psychometric_assessments.index
  kpi_assessments.index
  master_data.ids_staffs.index
  user_management.users.index / .show / .create / .update / .destroy
  user_management.roles.index / .show / .create / .update / .destroy
```

### Permission Check Flow

```
Controller action calls: authorize Record
    │
    ▼
Pundit resolves policy class (e.g., StaffProfilePolicy)
    │
    ▼
Policy method (e.g., index?) calls: user.has_permission?("staff_profiles.index")
    │
    ▼
User#has_permission? checks:
    ├─ return false if no role
    ├─ return true if superadmin? (role.name == "superadmin")
    └─ @permission_codes.include?(code)  ← cached per-request (memoized)
```

### Policy Scoping

```ruby
# ApplicationPolicy::Scope#resolve
if user.superadmin?
  scope.all                          # Sees everything
elsif user.has_permission?("resource.index")
  apply_role_based_scope             # Default: scope.all (override per policy)
else
  scope.none                         # No access
end
```

### Default Roles (from seeds)

| Role           | Permissions                                                                                                                                     |
| -------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| **superadmin** | All permissions                                                                                                                                 |
| **staff**      | dashboard.index, bi_dashboards.index, staff_profiles.index, psychometric_assessments.index, kpi_assessments.index, master_data.ids_staffs.index |

---

## 6. Routes Map

```ruby
root "dashboard#index"                          # GET /
get "dashboard"                                 # GET /dashboard

resources :bi_dashboards,           only: %i[index]
resources :staff_profiles,          only: %i[index show]
resources :psychometric_assessments, only: %i[index]
resources :kpi_assessments,         only: %i[index]

namespace :master_data do
  resources :ids_staffs, only: %i[index]
end

namespace :user_management do
  resources :roles do
    member { get :confirm_delete }
  end

  resources :users do
    member { get :confirm_delete }
  end
end
```

---

## 7. Controller Patterns & Conventions

### Index with Ransack + Pagy (standard pattern)

All controllers with a searchable listing include `RansackMultiSort`:

```ruby
class ThingsController < ApplicationController
  include RansackMultiSort

  def index
    authorize Thing

    apply_ransack_search(
      policy_scope(Thing).order(id: :desc)
    )
    @pagy, @things = paginate_results(@q.result)
  end
end
```

**Do NOT** inline `@q = scope.ransack(params[:q])` + `pagy(@q.result, limit: ...)` directly. Always use `apply_ransack_search` + `paginate_results` from the concern.

### `RansackMultiSort` concern (`app/controllers/concerns/ransack_multi_sort.rb`)

| Method                        | Purpose                                                                         |
| ----------------------------- | ------------------------------------------------------------------------------- |
| `apply_ransack_search(scope)` | Sets `@q = scope.ransack(params[:q])`                                           |
| `paginate_results(results)`   | Calls `pagy(results, limit: sanitized_per_page_param)` with overflow protection |
| `sanitized_per_page_param`    | Reads `params[:per_page]`, falls back to `Pagy.options[:limit] \|\| 10`         |

### CRUD pattern (user_management controllers)

```ruby
class UserManagement::ThingsController < ApplicationController
  include RansackMultiSort
  before_action :set_thing, only: %i[show edit update destroy confirm_delete]

  def index
    authorize Thing, policy_class: UserManagement::ThingPolicy

    apply_ransack_search(
      policy_scope(Thing, policy_scope_class: UserManagement::ThingPolicy::Scope)
        .order(id: :desc)
    )
    @pagy, @things = paginate_results(@q.result)
  end

  def show
    authorize @thing, policy_class: UserManagement::ThingPolicy
    redirect_to user_management_things_path unless turbo_frame_request?
  end

  def new
    @thing = Thing.new
    authorize @thing, policy_class: UserManagement::ThingPolicy
    redirect_to user_management_things_path unless turbo_frame_request?
  end

  def create
    @thing = Thing.new(thing_params)
    authorize @thing, policy_class: UserManagement::ThingPolicy

    if @thing.save
      respond_to do |format|
        format.turbo_stream { flash.now[:notice] = 'Created successfully.' }
        format.html { redirect_to user_management_things_path, notice: 'Created successfully.' }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def confirm_delete
    authorize @thing, policy_class: UserManagement::ThingPolicy
    turbo_frame_request? ? render(layout: false) : redirect_to(user_management_things_path)
  end

  def destroy
    authorize @thing, policy_class: UserManagement::ThingPolicy
    @thing.destroy
    respond_to do |format|
      format.turbo_stream { flash.now[:notice] = 'Deleted successfully.' }
      format.html { redirect_to user_management_things_path, notice: 'Deleted successfully.' }
    end
  end

  private

  def set_thing
    @thing = Thing.find(params[:id])
  end
end
```

### Modal guard (turbo_frame_request?)

Every action that renders modal content MUST guard:

```ruby
def show
  redirect_to things_path unless turbo_frame_request?
  # ... logic
end
```

---

## 8. Frontend Architecture

### JavaScript Stack

```
importmap-rails (NO Node.js, NO bundler)
    ├── @hotwired/turbo-rails  (turbo.min.js)
    ├── @hotwired/stimulus     (stimulus.min.js)
    ├── bootstrap              (bootstrap.min.js via gem)
    └── @popperjs/core         (popper.js via gem)
```

### Stimulus Controllers

| Controller    | File                        | Purpose                                         |
| ------------- | --------------------------- | ----------------------------------------------- |
| `flash`       | `flash_controller.js`       | Auto-dismiss flash messages                     |
| `modal`       | `modal_controller.js`       | Bootstrap modal lifecycle + Turbo Frame content |
| `search-form` | `search_form_controller.js` | Auto-submit search forms with debounce          |
| `sidebar`     | `sidebar_controller.js`     | Sidebar toggle, mobile collapse                 |

### Adding a New Stimulus Controller

1. Create `app/javascript/controllers/{name}_controller.js`
2. Auto-registers via `eagerLoadControllersFrom("controllers", application)`
3. Use in views: `data-controller="{name}"`

### Adding a New JS Library (ESM only)

```bash
curl -L -o vendor/javascript/lib.js "https://esm.sh/lib@version?bundle-deps"
```

Then pin in `config/importmap.rb`:

```ruby
pin "lib", to: "lib.js"
```

**IMPORTANT**: Only ESM modules work. UMD/CJS will fail with importmap.

### Turbo Patterns

1. **Turbo Drive**: SPA-like full-page navigation (default)
2. **Turbo Frames**: Modal content via `turbo_frame_tag "modal"`
3. **Turbo Streams**: In-place updates (flash messages, table refreshes)

---

## 9. CSS Architecture

```
dartsass-rails (SCSS compilation — NOT sassc-rails)

app/assets/stylesheets/
└── application.scss   # Imports Bootstrap + custom styles
```

No Node.js/PostCSS. Sass is compiled via the `dartsass-rails` gem.

---

## 10. Common Modification Scenarios

### Adding a New Permission-Protected Resource

1. Add migration + model
2. Add permission seeds in `db/seeds.rb`
3. Create policy inheriting `ApplicationPolicy`, implement `permission_resource`
4. Create controller:
   - Include `RansackMultiSort` if listing has search/pagination
   - Call `authorize` in every action
   - Use `policy_scope` for collection queries
5. Add routes in `config/routes.rb`
6. Add sidebar link guarded with `can_view_menu?("resource.index")`

### Adding a Searchable Index

```ruby
include RansackMultiSort

def index
  authorize Thing

  apply_ransack_search(policy_scope(Thing).order(id: :desc))
  @pagy, @things = paginate_results(@q.result)
end
```

---

## 11. Development Setup

```bash
# Using Docker
docker compose up -d
docker compose exec web rails db:create db:migrate db:seed

# Without Docker (local)
bundle install
rails db:create db:migrate db:seed
bin/dev

# Seed credentials
# Email: admin@pilotids.com / Password: password123
```

---

## 12. Code Style & Conventions

- **Frozen string literals**: All `.rb` files start with `# frozen_string_literal: true`
- **Soft delete**: Not used in this project — use `destroy`
- **Policy class**: Always explicitly pass `policy_class:` and `policy_scope_class:` when using namespaced policies
- **Strong params**: Always `params.require(:model).permit(...)`
- **Turbo modals**: Guard all modal-rendering actions with `turbo_frame_request?`
- **Search**: Always use `RansackMultiSort` concern — never inline ransack + pagy
- **Per-page**: Rely on `sanitized_per_page_param` from the concern — never write local `sanitize_per_page`
- **JS**: ES Modules only — no `require()`

---

## 13. File Modification Checklist

When modifying this codebase, verify:

- [ ] `# frozen_string_literal: true` at top of every Ruby file
- [ ] `authorize` call in every controller action
- [ ] `policy_scope` used for collection queries
- [ ] `RansackMultiSort` included for any controller with search/pagination
- [ ] `apply_ransack_search` + `paginate_results` used (not inline `ransack` + `pagy`)
- [ ] `turbo_frame_request?` guard on all modal-rendering actions
- [ ] New permissions added to `db/seeds.rb`
- [ ] Sidebar link guarded with `can_view_menu?`
- [ ] JS imports use ESM only
- [ ] Explicit `policy_class:` and `policy_scope_class:` for namespaced policies
