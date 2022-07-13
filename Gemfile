source "https://rubygems.org"

gem "rails", "7.0.3.1"

gem "aasm"
gem "generic_form_builder"
gem "inline_svg"
gem "kramdown"
gem "mysql2"
gem "sass-rails"
gem "sentry-sidekiq"
gem "sprockets-rails"
gem "uglifier"

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
  gem "factory_bot_rails"
  gem "faker"
  gem "govuk_schemas"
  gem "govuk_test"
  gem "nokogiri"
  gem "parser"
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
