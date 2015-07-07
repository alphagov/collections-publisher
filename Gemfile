source 'https://rubygems.org'

gem 'rails', '4.2.2'

gem 'mysql2', '~> 0.3.16'
gem 'plek', '~> 1.10.0'
gem 'airbrake', '~> 4.2.0'

gem 'gds-sso', '~> 11.0.0'
gem 'gds-api-adapters', '20.1.1'

gem 'govuk_admin_template', '~> 2.3.1'
gem 'generic_form_builder', '~> 0.9.0'
gem 'aasm', '~> 4.1.0'

gem 'sass-rails', '~> 5.0.3'
gem 'uglifier', '>= 1.3.0'
gem 'select2-rails', '~> 3.5.9'

gem 'unicorn', '~> 4.9.0'
gem 'logstasher', '0.6.5'

# sidekiq-web depends on sinatra
gem 'sinatra', require: nil
gem 'sidekiq', '~> 2.17.2'

gem 'byebug', group: [:development, :test]

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'quiet_assets', '~> 1.1.0'
end

group :test, :development do
  gem 'rspec-rails', '~> 3.2.1'
  gem 'capybara', '~> 2.4.1'
  gem 'poltergeist', '~> 1.6.0'
  gem 'database_cleaner', '~> 1.3.0'
  gem 'factory_girl_rails', '~> 4.5.0'
  gem 'webmock', '~> 1.21.0', require: false
  gem 'timecop', '~> 0.7.1'
  gem 'annotate', '~> 2.6.8'
  gem 'govuk-content-schema-test-helpers', '~> 1.3'
end
