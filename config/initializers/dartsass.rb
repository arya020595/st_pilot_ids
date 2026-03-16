# frozen_string_literal: true

# Silence deprecation warnings from third-party dependencies (e.g., Bootstrap)
# that still use legacy Sass features internally.
# See: https://sass-lang.com/documentation/cli/dart-sass/#quiet-deps
Rails.application.config.dartsass.build_options += ['--quiet-deps']
