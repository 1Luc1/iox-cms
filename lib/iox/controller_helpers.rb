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
          return redirect_to login_path
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
      return if session[:locale] and (session[:locale] == I18n.locale) and (!params.has_key?(:locale) or !request.get?)
      if params[:locale] && Rails.configuration.iox.available_langs.include?(params[:locale].downcase)
        I18n.locale = (session[:locale] = params[:locale])
      #elsif current_user and current_user.settings["locale"]
      #  I18n.locale = (session[:locale] = current_user.settings["locale"])
      #elsif request.env.has_key?("HTTP_ACCEPT_LANGUAGE") && detected_locale = request.env["HTTP_ACCEPT_LANGUAGE"][0..1]
      #  if Rails.configuration.i18n.available_locales && Rails::Application.config.i18n.available_locales.include?(detected_locale.downcase)
      #    I18n.locale = (session[:locale] = detected_locale)
      #  else
      #    session[:locale] = I18n.locale
      #  end
      else
        I18n.locale = session[:locale] = Rails.configuration.iox.available_langs.include?(I18n.locale.downcase) ? I18n.locale : I18n.default_locale
      end
    end

  end
end
