require_relative "boot"

# require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
# require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
# require "action_cable/engine"
require "sprockets/railtie"
require "tilt/erubi"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module CollectionsPublisher
  class Application < Rails::Application
    config.load_defaults "6.1"
    config.time_zone = "London"
    config.action_view.raise_on_missing_translations = true
    config.active_record.belongs_to_required_by_default = false

    config.action_mailer.notify_settings = {
      api_key: Rails.application.secrets.notify_api_key || "test-api-key",
    }

    unless Rails.env.production?
      ENV["JWT_AUTH_SECRET"] = "123"
    end

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Using a sass css compressor causes a scss file to be processed twice
    # (once to build, once to compress) which breaks the usage of "unquote"
    # to use CSS that has same function names as SCSS such as max.
    # https://github.com/alphagov/govuk-frontend/issues/1350
    config.assets.css_compressor = nil

    # Sets local to "true" in all forms that use form_with. This is only needed
    # until the application is upgraded to Rails 6.1.
    config.action_view.form_with_generates_remote_forms = false
  end
end
