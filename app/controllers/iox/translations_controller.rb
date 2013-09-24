require_dependency "iox/application_controller"

module Iox

  class TranslationsController < ApplicationController

    include Iox::WebpagesHelper

    before_filter :authenticate!

    def show
      @translation = Translation.where( webpage_id: params[:webpage_id], locale: params[:id] ).first
      render json: @translation
    end

    def create
      @webpage = Webpage.find_by_id( params[:webpage_id] )
      return if !redirect_if_no_webpage
      return if !redirect_if_no_rights
      @webpage.translation = @webpage.translations.build( locale: params[:locale] )
      if @webpage.save
        flash.now.notice = t('webpage.translation_created')
      else
        flash.now.alert = t('webpage.translation_creation_failed')
      end
      render json: { flash: flash, success: @webpage.persisted?, item: @webpage.translation }
    end

  end

end