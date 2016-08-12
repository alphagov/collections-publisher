source 'https://rubygems.org'

gem 'rails', '4.2.7.1'

# Note that mysql2 0.4.X doesn't work with Rails. 4.2.X yet.
gem 'mysql2', '~> 0.3.20'

gem 'plek', '~> 1.11.0'
gem 'airbrake', '~> 4.3.5'

gem 'gds-sso', '~> 11.0.0'
gem 'gds-api-adapters', '~> 30.2.0'

gem 'govuk_admin_template', '~> 4.1'
gem 'generic_form_builder', '~> 0.13.0'
gem 'aasm', '~> 4.3.0'

gem 'sass-rails', '~> 5.0.3'
gem 'uglifier', '>= 1.3.0'
gem 'select2-rails', '~> 3.5.9'

gem 'unicorn', '~> 4.9.0'
gem 'logstasher', '0.6.2'

# sidekiq-web depends on sinatra
gem 'sinatra', require: nil
gem 'govuk_sidekiq', '~> 0.0.4'

gem 'byebug', group: [:development, :test]

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'quiet_assets', '~> 1.1.0'
end

group :test, :development do
  gem 'capybara', '~> 2.5.0'
  gem 'database_cleaner', '~> 1.5.0'
  gem 'factory_girl_rails', '~> 4.5.0'
  gem 'govuk-content-schema-test-helpers', '~> 1.4'
  gem 'nokogiri', '~> 1.6.8'
  gem 'poltergeist', '~> 1.7.0'
  gem 'pry-byebug', '~> 3.4'
  gem 'rspec-rails', '~> 3.3.3'
  gem 'timecop', '~> 0.8.0'
  gem 'webmock', '~> 1.21.0', require: false
  gem 'govuk-lint'
end
