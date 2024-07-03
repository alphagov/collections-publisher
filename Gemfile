source "https://rubygems.org"

gem "rails", "7.1.3.4"

gem "aasm"
gem "bootsnap", require: false
gem "generic_form_builder"
gem "inline_svg"
gem "kramdown"
gem "mysql2"
gem "sass-rails"
gem "sentry-sidekiq"
gem "sprockets-rails"
gem "terser"

# GDS managed dependencies
gem "gds-api-adapters"
gem "gds-sso"
gem "govuk_app_config"
# gem "govuk_publishing_components"
gem "govuk_publishing_components", git: "https://github.com/alphagov/govuk_publishing_components.git", branch: "upgrade-to-govuk-frontend-5.1", ref: "29e8b077cdc6f69493805b67cbbec856dde008ea"
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
