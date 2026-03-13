# frozen_string_literal: true

# Pagy initializer
Pagy.options[:limit] = 10
Pagy.options[:limit_key] = 'per_page'
Pagy.options[:client_max_limit] = 100
Pagy.options[:max_pages] = 50
Pagy.options[:overflow] = :last_page
