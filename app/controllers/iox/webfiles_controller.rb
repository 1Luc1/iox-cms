require_dependency "iox/application_controller"

module Iox

  class WebfilesController < ApplicationController

    def destroy
      success = false
      if @webfile = Webfile.find_by_id( params[:id] )
        if @webfile.destroy
          flash.now.notice = t('deleted')
          success = true
        else
          flash.now.alert = t('deletion_failed')
        end
      else
        flash.now.alert = t('not_found')
      end
    end

  end

end