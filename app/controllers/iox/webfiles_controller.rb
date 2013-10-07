require_dependency "iox/application_controller"

module Iox

  class WebfilesController < ApplicationController

    before_filter :authenticate!

    include WebpagesHelper

    def create
      @webpage = Webpage.find_by_id( params[:webpage_id] )

      return if !redirect_if_no_webpage
      return if !redirect_if_no_rights

      @webfile = @webpage.webfiles.build name: params[:file].original_filename, content_type: params[:file].content_type
      @webfile.file = params[:file]
      if @webfile.save
        render :json => @webfile.to_jq_upload(:file)
      else
        render :json => [{:error => "custom_failure"}], :status => 304
      end
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

  end

end