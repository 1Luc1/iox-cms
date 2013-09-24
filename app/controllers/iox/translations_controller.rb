require_dependency "iox/application_controller"

module Iox

  class TranslationsController < ApplicationController

    before_filter :authenticate!

    def show
      @translation = Translation.where( webpage_id: params[:webpage_id], locale: params[:id] ).first
      render json: @translation
    end

  end

end