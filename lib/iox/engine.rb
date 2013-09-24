module Iox
  class Engine < ::Rails::Engine

    isolate_namespace Iox

    #initializer "assets_initializers.initialize_rails", :group => :assets do |app|
    #  require "#{Rails.root}/config/initializers/load_config.rb"
    #end

    initializer :assets do |config|
      Rails.application.config.assets.precompile << %w(
        iox/application.js
        iox/application.css
        iox/webpages.js
        iox/users.js
        iox/users.css
        iox/webpages.css
        iox/activities.css
        3rdparty/password-generator.min.js
        3rdparty/jquery.fileupload
        iox/avatar/original/missing.png
        iox/avatar/thumb/missing.png
        iox/loader.gif
        iox/loader-horizontal.gif
        3rdparty/kendoui/textures/highlight.png
      )
    end

    initializer :append_migrations do |app|
      unless app.root.to_s.match root.to_s
        config.paths["db/migrate"].expanded.each do |expanded_path|
          app.config.paths["db/migrate"] << expanded_path
        end
      end
    end

  end
end
