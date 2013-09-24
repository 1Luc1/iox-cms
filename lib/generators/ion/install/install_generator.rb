require 'rails/generators/migration'

module Ion
  module Generators
    class InstallGenerator < Rails::Generators::Base

      source_root File.expand_path('../templates', __FILE__)

      desc "Installs TASTENbOX into your application"

      def setup_and_create

        copy_file "favicon.ico", "public/favicon.ico"
        copy_file "gitignore", ".gitignore"

        copy_file "webpage_fixtures/default_data.yml",
          "config/ion_webpage_fixtures/default_data.yml"

        copy_file "webpage_templates/_default.html.erb",
          "app/views/ion/webpages/templates/_default.html.erb"

        copy_file "app-styles.js", "app/assets/javascripts/ion/app-styles.js"
        copy_file "app-templates.js", "app/assets/javascripts/ion/app-templates.js"

        directory "webfonts", "public/webfonts"
        directory "javascripts", "public/javascripts/3rdparty/"

        copy_file "application.html.erb", "app/views/layouts/application.html.erb"
        copy_file "application.css.scss", "app/assets/stylesheets/application.css.scss"
        remove_file "/app/assets/stylesheets/application.css"

        copy_file "ion_quota.yml", "config/ion_quota.yml"
        copy_file "deploy.rb", "config/deploy.rb"
        copy_file "whenever_schedule.rb", "config/schedule.rb"
        create_file "app/assets/stylesheets/ion/overrides.css.scss"

        gem 'rails-i18n', '~> 4.0.0.pre'
        # gem 'paperclip', '~> 3.0'
        # gem 'rails-i18n', '~> 0.7.4'
        # gem 'capistrano', group: :development
        # gem 'rvm-capistrano', group: :development
        # gem 'therubyracer', group: :production, platform: :ruby
        # gem 'select2-rails', '3.4.8'
        # gem 'jquery-rails'
        # gem 'rails_warden'
        # gem 'bcrypt-ruby'
        # gem 'whenever', :require => false

      end

      def setup_config

        app_name = File::basename Rails.root.to_s.sub('_','.')
        domain_name = app_name.include?('.') ? app_name : app_name+'.site'
        application do
          "\n"+
          "    # ION Defaults \n"+
          "    config.ion.site_title = '#{app_name}'\n"+
          "    config.ion.deny_apps = ['contacts']\n"+
          "    config.ion.domain_name = '#{domain_name}'\n"+
          "    config.ion.open_registration = false\n"+
          "    config.ion.redirect_after_login = '/ion/dashboard'\n"+
          "    config.ion.support_email = 'support@tastenwerk.com'\n"+
          "    config.ion.available_langs = [:de, :en]\n"+
          "    config.ion.user_roles = ['user','admin','editor']\n"+
          "    config.ion.user_default_roles = ['user']\n"+
          "    config.ion.addons_order = ['dashboard','webpages']\n"+
          "    config.ion.user_settings = { notify_on_new_content: false, notify_on_comment: false, notify_on_new_user: false }"+
          "\n"+
          "    config.ion.default_read_apps = ['dashboard']\n"+
          "    config.ion.default_write_apps = ['dashboard']\n"+
          "\n"+
          "    config.ion.brand_logo = 'ion/logo_transp_150x150.png'\n"+
          "\n"+
          "    config.ion.max_quota_mb = 500\n"+
          "    config.ion.session_timeout_min = 60\n"+
          "\n"+
          "    config.i18n.default_locale = :de\n"+
          "    config.i18n.available_locales = [:en, :de]\n"+
          "    config.time_zone = 'Vienna'\n"+
          "\n"+
          "    config.action_mailer.default_options = { from: 'no-reply@#{domain_name}' }"+
          "\n"+
          "\n"
        end
        application(nil, env: "production") do
          "\n"+
          "  # TASTENbOX configuration\n"+
          "\n"+
          "  config.action_mailer.delivery_method = :smtp\n" +
          "  config.action_mailer.smtp_settings = {\n" +
          "    address:              '<your mail host>',\n" +
          "    port:                 465,\n" +
          "    user_name:            '<your username>',\n" +
          "    password:             '<your password>',\n" +
          "    authentication:       'plain',\n" +
          "    enable_starttls_auto: true  }"+
          "\n"+
          "\n"+
          "  config.log_level = :warn"+
          "\n"+
          "\n"
        end

        route "root 'ion/webpages#frontpage'"
        route "get '/login', to: 'ion/auth#login'"
        route "mount Ion::Engine, at: 'ion'"

      end

    end
  end
end
