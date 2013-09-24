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
          flash.alert = I18n.t('auth.session_timeout', timeout: Rails.configuration.iox.session_timeout_min )
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

  end
end
