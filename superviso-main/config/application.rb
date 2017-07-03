require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module Superviso
  class Application < Rails::Application
    config.active_record.default_timezone = :utc
    # fallback to what's specified in config.i18n.default_locale
    config.i18n.fallbacks = true
    config.i18n.fallbacks = [:en]

  config.generators do |generate|
    generate.helper false
    generate.javascript_engine false
    generate.request_specs false
    generate.routing_specs false
    generate.stylesheets false
    generate.test_framework :rspec
    generate.view_specs false
  end
  config.assets.initialize_on_precompile = false
  config.assets.precompile += ['landing_page.js', 'only_dashing.js', 'landing_page.css', 'only_dashing.css']

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :en
  end
end
