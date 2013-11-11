module Iox
  class ApplicationController < ActionController::Base

    include Iox::ControllerHelpers
    include Iox::AccessControllerHelpers

    # Prevent CSRF attacks by raising an exception.
    # For APIs, you may want to use :null_session instead.
    protect_from_forgery with: :null_session

    layout 'iox/application'

    before_filter :set_locale

  end
end
