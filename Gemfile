source 'https://rubygems.org'

gem 'rails', '4.2.4'

# Note that mysql2 0.4.X doesn't work with Rails. 4.2.X yet.
gem 'mysql2', '~> 0.3.20'

gem 'plek', '~> 1.11.0'
gem 'airbrake', '~> 4.3.1'

gem 'gds-sso', '~> 11.0.0'
gem 'gds-api-adapters', '~> 26.3'

gem 'govuk_admin_template', '~> 3.0.0'
gem 'generic_form_builder', '~> 0.13.0'
gem 'aasm', '~> 4.3.0'

gem 'sass-rails', '~> 5.0.3'
gem 'uglifier', '>= 1.3.0'
gem 'select2-rails', '~> 3.5.9'

gem 'unicorn', '~> 4.9.0'
gem 'logstasher', '0.6.2'

# sidekiq-web depends on sinatra
gem 'sinatra', require: nil
gem 'sidekiq', '~> 2.17.2'
gem 'sidekiq-statsd', '0.1.5'

gem 'byebug', group: [:development, :test]

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'quiet_assets', '~> 1.1.0'
  gem 'govuk-lint', '0.5.0'
end

group :test, :development do
  gem 'rspec-rails', '~> 3.3.3'
  gem 'capybara', '~> 2.5.0'
  gem 'poltergeist', '~> 1.7.0'
  gem 'database_cleaner', '~> 1.5.0'
  gem 'factory_girl_rails', '~> 4.5.0'
  gem 'webmock', '~> 1.21.0', require: false
  gem 'timecop', '~> 0.8.0'
  gem 'govuk-content-schema-test-helpers', '~> 1.3'
end
