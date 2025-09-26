module Iox
  # Those helpers are convenience methods added to ApplicationController.
  module ControllerHelpers
    extend ActiveSupport::Concern

    included do
      helper_method :warden, :authenticated?, :current_user
    end

    # The main accessor for the warden proxy instance
    def warden
      request.env['warden']
    end

    # Return the current logged in user object
    #
    # current_user => #<Iox::User>
    #
    def current_user
      warden.user || nil
    end

    # Return true if a warden user object exists and is a valid user
    # object
    #
    #   authenticated?
    #
    def authenticated?
      !current_user.nil?
    end

    def authenticate!
      if warden.authenticate!
        if !current_user.last_request_at || current_user.last_request_at < Rails.configuration.iox.session_timeout_min.minutes.ago
          warden.logout
          flash.now.alert = I18n.t('auth.session_timeout', timeout: Rails.configuration.iox.session_timeout_min )
          return redirect_to '/iox/login'
        end
        current_user.update!( last_request_at: Time.now )
      end
    end

    def notify_401
      flash.now.alert = I18n.t('insufficient_rights')
    end

    def notify_404
      flash.now.alert = I18n.t('not_found')
    end

    def redirect_401
      flash.alert = I18n.t('insufficient_rights')
      redirect_to( Rails.configuration.iox.redirect_after_login || dashboard_path )
    end

    def render_401
      flash.alert = I18n.t('insufficient_rights')
      redirect_to( Rails.configuration.iox.redirect_after_login || dashboard_path )
      render template: 'common/render_401', layout: 'application'
    end

    def set_locale
      logger.debug "* Accept-Language: #{request.env['HTTP_ACCEPT_LANGUAGE']}"
      locale =  params[:locale] || extract_locale_from_accept_language_header || I18n.default_locale
      locale = locale.to_sym
      if get_available_langs.include? locale
        I18n.locale = locale
        logger.debug "* Locale set to '#{I18n.locale}'"
      else
        logger.debug "* Locale not included in #{Rails.configuration.iox.available_langs} could not set to '#{locale}'"
      end
    end

    # checks if current_user is owner of given object
    # or if user can write to the object's application type
    # or if user is admin.
    #
    # @return [boolean] if user can access
    #
    def can_modify?( obj )
      unless obj.respond_to?( :created_by )
        raise StandardError.new "obj does not respond to :created_by"
      end
      if !current_user.is_admin? && obj.created_by != current_user.id &&
         !( !current_user.can_write_apps.blank? && current_user.can_write_apps.include?(obj.class.demodulize.singularize) )
        flash.now.alert = t('insufficient_rights_you_cannot_save')
        return false
      end
      true
    end

    def quote_string(s)
      s.gsub(/\\/, '\&\&').gsub(/'/, "''") # ' (for ruby-mode)
    end

    private

    def extract_locale_from_accept_language_header
      return unless request.env['HTTP_ACCEPT_LANGUAGE']
      request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first
    end

    def get_available_langs
      if Rails.configuration.iox && Rails.configuration.iox.available_langs
        Rails.configuration.iox.available_langs
      else
        [ I18n.default_locale ]
      end
    end

  end
end
