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

    def new
      return render json: '' unless current_user.is_editor?
      if @webpage = Webpage.find_by_id( params[:webpage_id] )
        @webbit = @webpage.webbits.build plugin_type: 'text'
        render layout: false
      else
        render text: '', layout: false
      end
    end

    def create
      return render json: '' unless current_user.is_editor?
      if @webpage = Webpage.find_by_id( params[:webpage_id] )
        @webbit = Webbit.new webbit_params
        if @webbit.save
          flash.now.notice = t('webbit.created', name: @webbit.name )
        else
          flash.now.alert = t('webbit.failed_to_create')
        end
      else
        flash.alert = t('not_found')
      end
      render json: { flash: flash, item: @webbit, success: (flash.notice ? true : false) }

    end

    def destroy
      return render json: '' unless current_user.is_editor?
      if @webpage = Webpage.find_by_id( params[:webpage_id] )
        if @webbit = @webpage.webbits.where( id: params[:id] ).first
          if @webbit.delete
            flash.now.notice = t('webbit.deleted', name: @webbit.name )
          else
            flash.now.alert = t('webbit.deletion_failed', name: @webbit.name)
          end
        else
          flash.now.alert = t('webbit.not_found')
        end
      else
        flash.now.alert = t('not_found')
      end
      render json: { flash: flash, item: @webbit }
    end

    def webbit_params
      params.require(:webbit).permit(
        :name,
        :webpage_id,
        :plugin_type,
        :css_classes
        )
    end

  end
end