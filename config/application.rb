require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Spoop
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    # config.assets.paths << Rails.root.join('vendor', 'assets', 'bower_components')
    # config.assets.paths << Rails.root.join('vendor', 'assets', 'fonts')
    # config.assets.paths << %r(ionic/release/fonts/[\w-]+\.(?:eot|svg|ttf|woff2?)$)
    # config.assets.precompile += %w(*.svg *.eot *.woff *.ttf)
    # config.serve_static_assets = true
    config.time_zone = 'Eastern Time (US & Canada)'

    config.middleware.insert_before 0, "Rack::Cors" do
      allow do
        origins '*', 'localhost:3001', '127.0.0.1:3001'
        resource '*', :headers => :any, :methods => [:get, :delete, :put, :post, :options]
      end
    end
    
  end
end

require 'spoop_constants'