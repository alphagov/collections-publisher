source "https://rubygems.org"

gem "rails", "8.0.3"

gem "aasm"
gem "bootsnap", require: false
# connection_pool is a transitive dependency for sidekiq, but we need to pin it to < 3
# because sidekiq's support for connection_pool 3+ is only in sidekiq 8+
gem "connection_pool", "< 3"
gem "dartsass-rails"
gem "generic_form_builder"
gem "inline_svg"
gem "kramdown"
gem "mysql2"
gem "sentry-sidekiq"
gem "sprockets-rails"
gem "terser"

# GDS managed dependencies
gem "gds-api-adapters"
gem "gds-sso"
gem "govuk_app_config"
gem "govuk_publishing_components"
gem "govuk_sidekiq"
gem "mail-notify"
gem "plek"

group :development do
  gem "better_errors"
  gem "binding_of_caller"
end

group :development, :test do
  gem "byebug"
  gem "database_cleaner"
  gem "erb_lint", require: false
  gem "factory_bot_rails"
  gem "faker"
  gem "govuk_schemas"
  gem "govuk_test"
  gem "nokogiri"
  gem "pry-byebug"
  gem "rspec-rails"
  gem "rubocop-govuk"
  gem "shoulda-matchers"
  gem "simplecov"
  gem "timecop"
  gem "webmock", require: false
end

group :test do
  gem "rails-controller-testing"
end
