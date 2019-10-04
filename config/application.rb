require_relative "boot"

require "active_job/railtie"
require "active_model/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_view/railtie"
require "sprockets/railtie"

require "tilt/erubi"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module CollectionsPublisher
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.time_zone = "London"
    config.action_view.raise_on_missing_translations = true

    unless Rails.env.production?
      ENV["JWT_AUTH_SECRET"] = "123"
    end
  end
end
