# frozen_string_literal: true

source 'https://rubygems.org'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '~> 8.1.2', '>= 8.1.2.1'
# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem 'propshaft'
# Compile SCSS to CSS [https://github.com/rails/dartsass-rails]
gem 'dartsass-rails'
# Use postgresql as the database for Active Record
gem 'pg', '~> 1.6'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '>= 5.0'
# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem 'importmap-rails'
# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem 'turbo-rails'
# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem 'stimulus-rails'
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem 'jbuilder'

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem 'bcrypt', '~> 3.1.21'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[windows jruby]

# Use SQLite for Solid Cache, Queue, and Cable storage
gem 'sqlite3', '>= 2.1'

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem 'solid_cable'
gem 'solid_cache'
gem 'solid_queue'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem 'kamal', require: false

# Add HTTP asset caching/compression and target forwarding with Thruster [https://github.com/basecamp/thruster/]
gem 'thruster', require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem 'image_processing', '~> 1.2'

# Authentication
gem 'devise', '>= 5.0.3'

# Pagination
gem 'pagy'

# Authorization (Pundit policies)
gem 'pundit'

# Search and filtering
gem 'ransack'

# dry-rb: functional programming helpers
gem 'dry-monads', '~> 1.9'

# Strong Migrations to help write safe database migrations
gem 'strong_migrations'

# Bootstrap 5 framework integration
gem 'bootstrap', '~> 5.3'

# For handling PDF on Payslip Module
gem 'grover'

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[mri windows], require: 'debug/prelude'

  # Audits gems for known security defects (use config/bundler-audit.yml to ignore issues)
  gem 'bundler-audit', require: false

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem 'brakeman', require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem 'rubocop-rails-omakase', require: false

  # Annotate models with schema information
  gem 'annotate', require: false

  # Faker for generating fake data
  gem 'faker'

  # Bullet gem to help detect N+1 queries and unused eager loading
  gem 'bullet', '~> 8.1'
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem 'web-console'

  # Code completion and inline documentation for Ruby/Rails [https://solargraph.org]
  gem 'solargraph', '~> 0.58.2', require: false

  # HTML formatter for Ruby/Rails code [https://github.com/threedaymonk/htmlbeautifier]
  gem 'htmlbeautifier', require: false
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem 'capybara'
  gem 'selenium-webdriver'
end
