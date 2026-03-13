# ST Pilot IDS

A Rails 8.1 boilerplate application with authentication (Devise), authorization (Pundit), and user management.

## Tech Stack

- **Ruby** 3.4.7
- **Rails** ~> 8.1 (with `config.load_defaults 8.1`)
- **PostgreSQL** 16.1
- **Bootstrap** 5.3 (via Importmap)
- **Hotwire** (Turbo + Stimulus)
- **Propshaft** + Dart Sass for assets & SCSS
- **Solid Cache** / **Solid Queue** / **Solid Cable**
- **Kamal** for deployment, **Thruster** for HTTP acceleration

## Key Gems

| Gem                 | Purpose                      |
| ------------------- | ---------------------------- |
| `devise`            | Authentication               |
| `pundit`            | Authorization                |
| `pagy`              | Pagination                   |
| `ransack`           | Search & filtering           |
| `bootstrap` ~5.3    | UI framework                 |
| `dartsass-rails`    | SCSS compilation             |
| `propshaft`         | Asset pipeline               |
| `solid_cache`       | Database-backed caching      |
| `solid_queue`       | Database-backed job queue    |
| `solid_cable`       | Database-backed Action Cable |
| `kamal`             | Docker deployment            |
| `thruster`          | HTTP acceleration            |
| `strong_migrations` | Safe database migrations     |

## Getting Started

### Prerequisites

- [Docker](https://docs.docker.com/get-docker/) & Docker Compose
- Git

### Setup with Docker

1. **Clone the repository**

   ```bash
   git clone <repository-url>
   cd st_pilot_ids
   ```

2. **Copy environment file**

   ```bash
   cp .env.example .env
   ```

3. **Build and start services**

   ```bash
   docker compose build
   docker compose up -d
   ```

4. **Setup database**

   ```bash
   docker compose exec web rails db:create db:migrate db:seed
   ```

5. **Access the application**

   Open [http://localhost:3000](http://localhost:3000)

### Default Login

| Field    | Value                |
| -------- | -------------------- |
| Email    | `admin@pilotids.com` |
| Password | `password123`        |

## Environment Configuration

Copy `.env.example` to `.env` and adjust values:

```bash
# Database
DATABASE_HOST=db
DATABASE_PORT=5432
DATABASE_USERNAME=postgres
DATABASE_PASSWORD=root
DATABASE_NAME=st_pilot_ids_development

# Redis
REDIS_URL=redis://redis:6379/0

# Rails
RAILS_ENV=development
SECRET_KEY_BASE=your_secret_key_base_here

# Application
APP_HOST=localhost
APP_PORT=3000
APP_COMPANY_NAME=Pilot IDS
APP_COMPANY_FULL_NAME=Pilot IDS Sdn. Bhd.
```

## Docker Services

| Service | Image                       | Port |
| ------- | --------------------------- | ---- |
| `web`   | Ruby 3.4.7 (Dockerfile.dev) | 3000 |
| `db`    | postgres:16.1-alpine        | 5432 |
| `redis` | redis:7-alpine              | 6379 |

## Project Structure

```
app/
├── controllers/
│   ├── application_controller.rb    # Pundit, Pagy, Devise integration
│   ├── dashboard_controller.rb      # Main dashboard
│   ├── users/sessions_controller.rb # Custom Devise sessions
│   └── user_management/
│       ├── users_controller.rb      # User CRUD
│       └── roles_controller.rb      # Role CRUD
├── models/
│   ├── user.rb            # Devise user with role-based permissions
│   ├── role.rb            # Role with many permissions
│   ├── permission.rb      # Permission codes (e.g., dashboard.index)
│   └── role_permission.rb # Join table
├── policies/
│   ├── application_policy.rb        # Base policy with permission checks
│   ├── dashboard_policy.rb
│   └── user_management/
│       ├── user_policy.rb
│       └── role_policy.rb
├── views/
│   ├── layouts/
│   │   ├── application.html.erb     # Public/Devise layout
│   │   ├── dashboard/application.html.erb # Authenticated layout
│   │   └── devise/application.html.erb    # Auth pages layout
│   ├── dashboard/
│   ├── devise/sessions/
│   ├── user_management/users/
│   ├── user_management/roles/
│   └── shared/                      # Reusable partials (modal, flash, etc.)
└── assets/stylesheets/
    ├── application.scss   # Main stylesheet with Bootstrap imports
    ├── login.scss         # Login page styles
    ├── dashboard.scss     # Dashboard styles
    ├── sidebar.scss       # Sidebar navigation
    └── breadcrumb.scss    # Breadcrumb styles
```

## Authorization Pattern

The app uses a **permission-based** authorization system:

- **Roles** have many **Permissions** through **RolePermissions**
- Permission codes follow the pattern: `resource.action` (e.g., `user_management.users.create`)
- The `superadmin` role bypasses all permission checks
- Policies check permissions via `user.has_permission?(code)`

## Development Commands

```bash
# Start services
docker compose up -d

# Stop services
docker compose down

# View logs
docker compose logs -f web

# Rails console
docker compose exec web rails console

# Run migrations
docker compose exec web rails db:migrate

# Reset database
docker compose exec web rails db:drop db:create db:migrate db:seed

# Run tests
docker compose exec web rails test
```

## Adding New Features

1. **Create a migration** for your new model
2. **Create the model** with ransackable attributes
3. **Create a policy** extending `ApplicationPolicy` with `permission_resource`
4. **Add permissions** in `db/seeds.rb`
5. **Create controller** with Pundit authorization
6. **Add routes** in `config/routes.rb`
7. **Create views** using the existing patterns (modals, turbo streams)
8. **Add sidebar entry** in `app/views/layouts/dashboard/_sidebar.html.erb`
