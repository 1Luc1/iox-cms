module Ion
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
    # current_user => #<Ion::User>
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
      warden.authenticate!
    end

  end
end
