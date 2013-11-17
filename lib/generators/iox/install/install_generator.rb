require 'rails/generators/migration'

module Iox
  module Generators
    class InstallGenerator < Rails::Generators::Base

      source_root File.expand_path('../templates', __FILE__)

      desc "Installs TASTENbOX into your application"

      def setup_and_create

        copy_file "favicon.ico", "public/favicon.ico"
        copy_file "gitignore", ".gitignore"

        copy_file "webpage_fixtures/default_data.yml",
          "config/iox_webpage_fixtures/default_data.yml"

        copy_file "webpage_templates/_default.html.erb",
          "app/views/iox/webpages/templates/_default.html.erb"

        copy_file "app-styles.js", "public/javascripts/iox/app-styles.js"
        copy_file "app-templates.js", "public/javascripts/iox/app-templates.js"

        directory "webfonts", "public/webfonts"
        directory "javascripts", "public/javascripts/3rdparty/"

        copy_file "application.html.erb", "app/views/layouts/application.html.erb"
        copy_file "application.css.scss", "app/assets/stylesheets/application.css.scss"

        directory "avatar", "public/images/iox/avatar"
        directory "kendoui", "public/stylesheets/3rdparty/kendoui"
        directory "javascripts/ckeditor", "public/javascritps/3rdparty/ckeditor"
        directory "javascripts/ace-noconflict", "public/javascritps/3rdparty/ace-noconflict"

        remove_file "app/assets/stylesheets/application.css"

        copy_file "iox_quota.yml", "config/iox_quota.yml"
        copy_file "deploy.rb", "config/deploy.rb"
        copy_file "whenever_schedule.rb", "config/schedule.rb"
        create_file "app/assets/stylesheets/iox/overrides.css.scss"

        gem 'rails-i18n', '~> 4.0.0.pre'
        gem 'paperclip', '~> 3.0'
        # gem 'rails-i18n', '~> 0.7.4'
        # gem 'capistrano', group: :development
        gem "capistrano", "~ 2", group: :development
        # gem 'rvm-capistrano', group: :development
        # gem 'therubyracer', group: :production, platform: :ruby
        gem 'select2-rails', '3.4.8'
        gem 'premailer-rails', '~> 1.5.1'
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
          "    # ioX Defaults \n"+
          "    config.iox.site_title = '#{app_name}'\n"+
          "    config.iox.deny_apps = ['contacts']\n"+
          "    config.iox.domain_name = '#{domain_name}'\n"+
          "    config.iox.open_registration = false\n"+
          "    config.iox.redirect_after_login = '/iox/dashboard'\n"+
          "    config.iox.redirect_after_logout = '/iox/login'\n"+
          "    config.iox.support_email = 'support@tastenwerk.com'\n"+
          "    config.iox.available_langs = [:de, :en]\n"+
          "    config.iox.user_roles = ['user','admin','editor']\n"+
          "    config.iox.user_default_roles = ['user']\n"+
          "    config.iox.skip_plugins = []\n"+
          "    config.iox.addons_order = ['dashboard','webpages']\n"+
          "    config.iox.user_settings = { notify_on_new_content: false, notify_on_comment: false, notify_on_new_user: false }"+
          "\n"+
          "    config.iox.default_read_apps = ['dashboard']\n"+
          "    config.iox.default_write_apps = ['dashboard']\n"+
          "\n"+
          "    config.iox.brand_logo = 'iox/logo_transp_150x150.png'\n"+
          "\n"+
          "    config.iox.webfile_sizes = { original: '800x800>', thumb: '100x100' }\n"+
          "\n"+
          "    config.iox.cloud_storage_path = 'cloud-storage/'\n"+
          "\n"+
          "    config.iox.max_quota_mb = 500\n"+
          "    config.iox.session_timeout_min = 60\n"+
          "    config.iox.exception_recipients = [ 'errors@tastenwerk.com' ]\n"+
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
          "  # ioX configuration\n"+
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

        route "root 'iox/webpages#frontpage'"
        route "get '/login', to: 'iox/auth#login'"
        route "mount Iox::Engine => 'iox', as: 'iox'"

      end

    end
  end
end
