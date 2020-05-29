require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Flywheel
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    config.react.variant      = :production
    config.react.addons       = true

    config.generators do |g|
      g.orm :active_record
    end

    config.to_prepare do
      Devise::SessionsController.skip_before_action :find_app
      Devise::OmniauthCallbacksController.skip_before_action :find_app
    end
  end
end
