module Iox
  class Engine < ::Rails::Engine

    isolate_namespace Iox

    initializer "assets_initializers.initialize_rails", :group => :assets do |app|
      require "#{Rails.root}/config/initializers/load_config.rb"
    end

    initializer :assets do |config|
      Rails.application.config.assets.precompile << %w(
        iox/application.js
        iox/application.css
        iox/users.js
        iox/users.css
        iox/webpages.js
        iox/webpages_ext.js
        iox/webpages.css
        iox/webpages_ext.css
        iox/dashboard.css
        iox/dashboard.js
        iox/activities.css
        3rdparty/password-generator.min.js
        3rdparty/jquery.fileupload
        iox/loader.gif
        iox/loader-horizontal.gif
      )
    end

    initializer :append_migrations do |app|
      unless app.root.to_s.match root.to_s
        config.paths["db/migrate"].expanded.each do |expanded_path|
          app.config.paths["db/migrate"] << expanded_path
        end
      end
    end


    initializer :iox_exception_notifier do |app|
      # Exception Notification
      puts "SETUP ESCEPTION HANDLER"
      config.middleware.use Iox::ExceptionNotifier, {
       :exception_recipients => Rails.configuration.iox.exception_recipients
      }
    end


  end
end
