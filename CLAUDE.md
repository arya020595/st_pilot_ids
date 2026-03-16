# CLAUDE.md — Claude Code / Claude Agent Context for ST Pilot IDS

> **For Claude (Anthropic)**: This file contains structured context to help you understand, navigate, and modify the ST Pilot IDS codebase efficiently. Read this file first before making any changes.

---

## Identity

- **Project**: ST Pilot IDS — Internal Staff Profile & Assessment Management System
- **Stack**: Rails 8.1, PostgreSQL, Hotwire (Turbo + Stimulus), Bootstrap 5.3, importmap-rails, dartsass-rails
- **Auth**: Devise (authentication) + Pundit (authorization with permission codes)
- **Container**: Docker Compose (`web` + `db` services)

---

## Quick Reference — File Locations

| Task                                  | Files to touch                                                                      |
| ------------------------------------- | ----------------------------------------------------------------------------------- |
| Add a new page/feature                | `config/routes.rb`, new controller, new policy, new views, sidebar partial          |
| Change permissions                    | `db/seeds.rb` (permission definitions), run `rails db:seed`                         |
| Add a model                           | `db/migrate/`, `app/models/`                                                        |
| Add authorization                     | `app/policies/` — inherit from `ApplicationPolicy`, implement `permission_resource` |
| Add search/pagination to a controller | Include `RansackMultiSort`, use `apply_ransack_search` + `paginate_results`         |
| Add a Stimulus controller             | `app/javascript/controllers/{name}_controller.js` (auto-registered)                 |
| Add a JS library                      | `vendor/javascript/`, `config/importmap.rb`                                         |
| Change layout/nav                     | `app/views/layouts/dashboard/` (navbar, sidebar partials)                           |
| Add flash messages to modal form      | Add `format.turbo_stream` + `.turbo_stream.erb` view                                |
| Modify CSS                            | `app/assets/stylesheets/` (SCSS, compiled via dartsass-rails)                       |

---

## Architecture Mental Model

```
USER (Browser)
  │  Turbo Drive / Turbo Frames / Turbo Streams
  ▼
RAILS APP
  ├── Devise ──────── Authentication (session-based)
  ├── Pundit ──────── Authorization (permission code checks)
  ├── Controllers ─── RansackMultiSort concern for search/pagination
  ├── Models ──────── Validations + associations
  ├── Policies ────── Permission checks + scope filtering
  └── Views ───────── ERB + Turbo Frame/Stream responses
  │
  ▼
PostgreSQL
```

---

## Domain Model

```
Role ──has_many──→ RolePermission ──belongs_to──→ Permission
User ──belongs_to──→ Role
StaffProfile  (standalone, custom PK: staff_profile_id)
```

### Key Invariants

1. **Superadmin users** have `role.name == "superadmin"` — bypass ALL permission checks
2. **`staff_profiles`** has a custom primary key: `staff_profile_id` (not `id`)
3. No soft deletes — use `destroy` for deletion
4. No counter caches

---

## Permission System (CRITICAL)

### Permission Codes

```
Format: {namespace.}{resource}.{action}

All current codes:
  dashboard.index
  bi_dashboards.index
  staff_profiles.index
  staff_profiles.show         ← note: show is a separate permission here
  psychometric_assessments.index
  kpi_assessments.index
  master_data.ids_staffs.index
  user_management.users.index / .show / .create / .update / .destroy
  user_management.roles.index / .show / .create / .update / .destroy
```

### How it works

```ruby
# In controller:
authorize StaffProfile, policy_class: StaffProfilePolicy   # collection check
authorize @staff_profile, policy_class: StaffProfilePolicy # instance check
policy_scope(StaffProfile, policy_scope_class: StaffProfilePolicy::Scope)

# ApplicationPolicy auto-builds codes:
def index? = user.has_permission?("#{permission_resource}.index")

# User#has_permission?:
def has_permission?(code)
  return false unless role
  return true if superadmin?           # role.name == "superadmin"
  @permission_codes ||= role.permissions.pluck(:code)   # memoized
  @permission_codes.include?(code)
end
```

### Adding a new permission-protected resource

1. `db/seeds.rb` — add permission entries
2. Create policy:

   ```ruby
   class ThingPolicy < ApplicationPolicy
     private
     def permission_resource = "things"

     class Scope < ApplicationPolicy::Scope
       private
       def permission_resource = "things"
     end
   end
   ```

3. Controller: `authorize Thing` + `policy_scope(Thing)`
4. Sidebar: `<% if can_view_menu?("things.index") %>`

---

## Controller Conventions

### CRITICAL: RansackMultiSort Concern

**Always** use the `RansackMultiSort` concern for any controller with a searchable/paginated listing.

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

**NEVER** write inline ransack + pagy:

```ruby
# ❌ WRONG — do not do this:
@q = policy_scope(Thing).order(id: :desc).ransack(params[:q])
@pagy, @things = pagy(@q.result, limit: @per_page)
```

The concern (`app/controllers/concerns/ransack_multi_sort.rb`) provides:

- `apply_ransack_search(scope)` — sets `@q`
- `paginate_results(results)` — paginates with overflow protection
- `sanitized_per_page_param` — reads `params[:per_page]`, fallback to Pagy default

### Namespaced controllers — always explicit policy classes

```ruby
# ✅ CORRECT:
authorize User, policy_class: UserManagement::UserPolicy
policy_scope(User, policy_scope_class: UserManagement::UserPolicy::Scope)

# ❌ Never rely on implicit resolution for namespaced policies
```

### Modal guard

Every action rendering modal content (show, new, edit, confirm_delete) must guard:

```ruby
def show
  authorize @thing, policy_class: ThingPolicy
  redirect_to things_path unless turbo_frame_request?
end
```

### Turbo Stream response for CRUD

```erb
<%# things/create.turbo_stream.erb %>
<%= turbo_stream.update "things-table-body" do %>
  <%= render partial: "thing_row", collection: @things, as: :thing %>
<% end %>

<%= turbo_stream.update "flash-messages" do %>
  <%= render "layouts/flash" %>
<% end %>
```

**Always use `turbo_stream.update`** (not `replace`) for table body refreshes — `replace` removes the `<tbody id="...">` wrapper, breaking subsequent stream operations.

---

## Database Notes

- PostgreSQL
- `staff_profiles` has custom primary key `staff_profile_id` — use `.find_by(staff_profile_id: params[:id])` or ensure routes/model are configured correctly
- No soft deletes anywhere in this project
- Seeds: `admin@pilotids.com` / `password123` (superadmin role)

---

## Frontend Architecture

### No Node.js, No Bundler

Uses `importmap-rails` for native ESM. All JS must be ESM format. UMD/CJS will fail.

```ruby
# config/importmap.rb
pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus",    to: "stimulus.min.js"
pin "bootstrap",             to: "bootstrap.min.js", preload: true
pin "@popperjs/core",        to: "popper.js",        preload: true
pin_all_from "app/javascript/controllers", under: "controllers"
```

### CSS: dartsass-rails

Bootstrap is compiled from SCSS via `dartsass-rails` (not `sassc-rails`).

### Stimulus Controllers

| Controller    | Purpose                                      |
| ------------- | -------------------------------------------- |
| `flash`       | Auto-dismiss flash messages after N seconds  |
| `modal`       | Bootstrap modal + Turbo Frame integration    |
| `search-form` | Debounced form auto-submit for search inputs |
| `sidebar`     | Toggle sidebar visibility on mobile          |

---

## Common Pitfalls

### 1. Ransack inline — DON'T

Don't inline `scope.ransack(params[:q])` + `pagy(...)` in controllers. Always use `RansackMultiSort` concern.

### 2. Missing policy_class for namespaced resources

`UserManagement::UsersController` must pass `policy_class: UserManagement::UserPolicy` explicitly to every `authorize` and `policy_scope` call.

### 3. turbo_stream.replace destroys table body IDs

Use `turbo_stream.update` for table body refreshes, not `replace`. `replace` removes the `<tbody id="...">` element from the DOM.

### 4. Modal content renders on page refresh

Any action that renders modal-structured HTML must have `redirect_to index_path unless turbo_frame_request?`. Without this, directly navigating to `/things/1` renders the modal template as a full page.

### 5. staff_profiles custom PK

The `staff_profiles` table uses `staff_profile_id` as the primary key. Ensure the model declares `self.primary_key = "staff_profile_id"` and routes/finders account for this.

### 6. Permission cache

`User#has_permission?` memoizes `@permission_codes`. If you change a user's role in tests, call `user.clear_permission_cache!` before checking permissions again.

---

## Code Style

- `# frozen_string_literal: true` — top of every `.rb` file
- `authorize` — in every controller action (no exceptions)
- `policy_scope` — for every collection query (never `Model.all` directly)
- `RansackMultiSort` — for every index with search/pagination
- Snake_case files, CamelCase classes
- ERB views (not Haml/Slim)
- ES Modules only in JavaScript
- No `ENV.fetch` for production-only env vars in `database.yml` (use `ENV["KEY"]`)

---

## Testing

```bash
docker compose exec web rails test           # All unit + integration tests
docker compose exec web rails test:system    # Browser tests (Capybara)
```
