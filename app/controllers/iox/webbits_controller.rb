require_dependency "iox/application_controller"

module Iox

  class WebbitsController < ApplicationController

    before_filter :authenticate!

    def index
      return render json: '' unless current_user.is_editor?
      if @webpage = Webpage.find_by_id( params[:webpage_id] )
        @webbits = @webpage.webbits
        parent_id = params[:parent_id].blank? ? nil : params[:parent_id]
        @webbits = @webbits.where(parent_id: parent_id).load
        render json: @webbits
      end
    end

    def destroy
      return render json: '' unless current_user.is_editor?
      if @webpage = Webpage.find_by_id( params[:webpage_id] )
        if @webbit = @webpage.webbits.where( id: params[:id] ).first
          if @webbit.delete
            flash.notice = t('webbit.deleted', name: @webbit.name )
          else
            flash.alert = t('webbit.deletion_failed', name: @webbit.name)
          end
        else
          flash.alert = t('webbit.not_found')
        end
      else
        flash.alert = t('not_found')
      end
      render json: { flash: flash, webbit: @webbit }
    end

  end
end