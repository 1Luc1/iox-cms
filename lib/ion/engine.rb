module Ion
  class Engine < ::Rails::Engine

    isolate_namespace Ion

    initializer "assets_initializers.initialize_rails", :group => :assets do |app|
      require "#{Rails.root}/config/initializers/load_config.rb"
    end

    initializer :assets do |config|
      Rails.application.config.assets.precompile << %w( ion/application.js ion/application.css ion/webpages.js ion/webpages.css )
      Rails.application.config.assets.precompile << %w( 3rdparty/password-generator.min.js )
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
