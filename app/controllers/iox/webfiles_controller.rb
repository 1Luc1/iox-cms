require_dependency "iox/application_controller"

module Iox

  class WebfilesController < ApplicationController

    before_action :authenticate!

    include WebpagesHelper

    def index
      @webpage = Webpage.find_by_id( params[:webpage_id] )
      @order = params[:sort] ? params[:sort]['0'][:field] : 'name'
      @webfiles = @webpage.webfiles.order(@order)
      render json: @webfiles
    end

    def create
      @webpage = Webpage.find_by_id( params[:webpage_id] )

      return if !redirect_if_no_webpage
      return if !redirect_if_no_rights

      @webfile = @webpage.webfiles.build name: params[:file].original_filename, content_type: params[:file].content_type
      @webfile.file = params[:file]

      @webfile.set_creator_and_updater( current_user )

      if @webfile.save
        render :json => @webfile.to_jq_upload(:file)
      else
        render :json => [{:error => "custom_failure"}], :status => 304
      end
    end

    def update
      if @webfile = Webfile.find_by_id( params[:id] )
        if @webfile.update webfile_params
          flash.notice = t('webfile.saved', name: @webfile.name )
        else
          flash.alert = t('webfile.saving_failed', name: @webfile.name, error: @webfile.errors.full_messages.inspect )
        end
      else
        notify_404
      end
      render json: { flash: flash, success: flash[:alert].blank?, item: @webfile }
    end

    def destroy
      success = false
      if @webfile = Webfile.find_by_id( params[:id] )
        if @webfile.destroy
          flash.now.notice = t('deleted')
          success = true
          flash.now.notice = t('webfile.deleted', name: @webfile.name)
        else
          flash.now.alert = t('deletion_failed')
        end
      else
        flash.now.alert = t('not_found')
      end
      render json: { flash: flash, success: success, item: @webfile }
    end

    private

    def webfile_params
      params.require(:webfile).permit(:name, :description, :copyright)
    end

  end

end