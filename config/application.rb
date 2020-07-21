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

    config.react.jsx_transform_options = {
      optional: ['es7.classProperties']
    }

    config.generators do |g|
      g.orm :active_record
    end

    Rails.application.config.active_record.belongs_to_required_by_default = false

    config.to_prepare do
      Devise::SessionsController.skip_before_action :find_app
      Devise::OmniauthCallbacksController.skip_before_action :find_app
    end

    config.force_ssl = true
    config.ssl_options = {
      redirect: {
        exclude: -> req { env=req.env; env['PATH_INFO'] == '/' && env['HTTP_USER_AGENT'] && env['HTTP_USER_AGENT'].starts_with?('ELB-HealthChecker') }
      }
    }
    config.active_job.queue_adapter = :sidekiq

  end
end
