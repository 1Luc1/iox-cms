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
        flash.now.alert = t('not_found')
      end
      render json: { flash: flash, item: @webbit, success: (flash.notice ? true : false) }
    end

    def update
      return render json: '' unless current_user.is_editor?
      if @webpage = Webpage.find_by_id( params[:webpage_id] )
        if @webbit = Webbit.where( id: params[:id] ).first
          if @webbit.update webbit_params
            unless @webbit.template.blank?
              @webbit.translation.template = @webbit.template
            end
            unless @webbit.content.blank?
              @webbit.translation.content = @webbit.content
            end
            unless @webbit.title.blank?
              @webbit.translation.title = @webbit.title
            end
            @webbit.translation.save
            flash.now.notice = t('saved', name: @webbit.name )
          else
            flash.now.alert = t('saving_failed', name: @webbit.name)
          end
        else
          flash.now.alert = t('webbit.not_found')
        end
      else
        flash.now.alert = t('not_found')
      end
      render json: { flash: flash, item: @webbit }
    end

    def reorder
      errors = []
      if @webpage = Webpage.find_by_id( params[:webpage_id] )
        if params[:order] && params[:order].size > 0
          params[:order].each_with_index do |id,i|
            webbit = Webbit.find_by_id( id )
            errors << webbit unless webbit.update position: i
          end
          if changed_webbit = Webbit.find_by_id( params[:webbit_id] )
            changed_webbit.parent = params[:parent_id].blank? ? nil : Webbit.find_by_id( params[:parent_id] )
            errors << changed_webbit unless changed_webbit.save
            flash.now.notice = t('webbit.new_order_saved')
          else
            flash.now.alert = t('webbit.not_found')
          end
        end
      else
        flash.now.alert = t('not_found')
      end
      render json: { flash: flash, success: errors.blank?, errors: errors }
    end

    def destroy
      return render json: '' unless current_user.is_editor?
      if @webpage = Webpage.find_by_id( params[:webpage_id] )
        if @webbit = Webbit.where( id: params[:id] ).first
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
        :category,
        :css_classes,
        :title,
        :template,
        :content
        )
    end

  end
end