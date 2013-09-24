module Ion
  class Engine < ::Rails::Engine

    isolate_namespace Ion

    #initializer "assets_initializers.initialize_rails", :group => :assets do |app|
    #  require "#{Rails.root}/config/initializers/load_config.rb"
    #end

    initializer :assets do |config|
      Rails.application.config.assets.precompile << %w(
        ion/application.js
        ion/application.css
        ion/webpages.js
        ion/users.js
        ion/users.css
        ion/webpages.css
        ion/activities.css
        3rdparty/password-generator.min.js
        3rdparty/jquery.fileupload
        ion/avatar/original/missing.png
        ion/avatar/thumb/missing.png
        ion/loader.gif
        ion/loader-horizontal.gif
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
