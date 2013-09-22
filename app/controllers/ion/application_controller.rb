module Ion
  class ApplicationController < ActionController::Base

    include Ion::ControllerHelpers

    # Prevent CSRF attacks by raising an exception.
    # For APIs, you may want to use :null_session instead.
    protect_from_forgery with: :exception

    layout 'ion/application'

    before_filter :set_locale

    def set_locale
      return if session[:locale] and !params.has_key?(:locale)
      if params[:locale] && Tas10box.defaults[:locales].include?(params[:locale].downcase)
        I18n.locale = (session[:locale] = params[:locale])
      elsif current_user and current_user.settings["locale"]
        I18n.locale = (session[:locale] = current_user.settings["locale"])
      #elsif request.env.has_key?("HTTP_ACCEPT_LANGUAGE") && detected_locale = request.env["HTTP_ACCEPT_LANGUAGE"][0..1]
      #  if Rails.configuration.i18n.available_locales && Rails::Application.config.i18n.available_locales.include?(detected_locale.downcase)
      #    I18n.locale = (session[:locale] = detected_locale)
      #  else
      #    session[:locale] = I18n.locale
      #  end
      else
        session[:locale] = I18n.locale
      end
    end

  end
end
