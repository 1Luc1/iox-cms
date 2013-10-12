require_dependency "iox/application_controller"

module Iox
  class WebpagesController < ApplicationController

    include Iox::WebpagesHelper

    before_filter :authenticate!, except: [ :frontpage, :show, :by_slug ]

    #
    # shows the frontpage
    # the frontpage is of template type 'frontpage' and there should
    # only be one
    def frontpage
      @webpage = Webpage.where( template: 'frontpage', deleted_at: nil ).first
      init_webpage_translation
      update_stat
      return if !redirect_if_no_webpage
      render layout: 'application'
    end

    def name
      @webpage = Webpage.where( slug: params[:id] )
    end

    #
    # list all webpages
    #
    def index
      if request.xhr?
        @num_webpages = Webpage.count
        offset = params[:page] || 0
        limit = params[:limit] || 20
        if params[:parent].blank?
          query = "parent_id IS NULL"
        else
          query = "parent_id = '#{params[:parent]}'"
        end
        @webpages = Webpage.where( query ).limit( limit ).offset( offset ).order(:position).load.map{ |webpage|
          webpage.translation = webpage.translations.where( locale: params[:locale] || I18n.default_locale ).first
          webpage
        }
        render json: { items: @webpages }
      else
        @webpage = Webpage.new template: 'default'
        @webpage.translation = @webpage.translations.build( locale: I18n.default_locale )
      end
    end

    #
    # show form for new webpage
    #
    def new
      @webpage = Webpage.new template: 'default'
      @webpage.parent_id = params[:parent] unless params[:parent].blank?
      @parent = @webpage.parent if( @webpage.parent_id )
      render json: @webpage
    end

    #
    # show this webpage
    #
    def show
      @webpage = Webpage.find_by_id( params[:id] )
      init_webpage_translation
      return if !redirect_if_no_webpage
      update_stat
      render layout: 'application'
    end

    def by_slug
      @webpage = Webpage.where( slug: params[:slug] ).first
      init_webpage_translation
      return if !redirect_if_no_webpage
      update_stat
      render layout: 'application', template: 'iox/webpages/show'
    end

    def delete_webbit_from
      @webpage = Webpage.find_by_id( params[:id] )

      return if !redirect_if_no_webpage
      return if !redirect_if_no_rights

      @webbit = @webpage.webbits.where( id: params[:webbit_id] ).first
      if @webbit.destroy
        flash.now.notice = 'webbit removed'
      else
        flash.now.alert = 'webbit could not be removed'
      end
    end

    def images
      result = []
      found = false
      if params[:id]
        @webpage = Webpage.find_by_id( params[:id] )
        if @webpage
          @webpage.images.each do |img|
            result << { orig_url: img.file.url, thumb_url: img.file.url(:thumb), id: img.id }
          end
          found = true
        end
      end
      unless found
        Iox::Webfile.where("content_type LIKE 'image%'").each do |img|
          result << { orig_url: img.file.url, thumb_url: img.file.url(:thumb), id: img.id }
        end
      end
      render :json => result
    end

    #
    # publish a webpage
    #
    def publish
      @webpage = Webpage.find_by_id( params[:id] )

      return if !redirect_if_no_webpage
      return if !redirect_if_no_rights

      if params[:publish] == "true"
        @webpage.published = true
      else
        @webpage.published = false
      end
      if @webpage.save
        if @webpage.published?
          flash.now.notice = t('webpage.has_been_published', name: @webpage.name)
        else
          flash.now.notice = t('webpage.has_been_unpublished', name: @webpage.name)
        end
      else
        flash.now.alert = 'unknown error'
      end
      render :json => { flash: flash, success: flash[:alert].blank?, published: @webpage.published? }
    end

    #
    # create new webpage
    #
    def create
      @webpage = Webpage.new webpage_params
      return if !redirect_if_no_rights
      @webpage.set_creator_and_updater( current_user )
      @webpage.translation = @webpage.translations.build( locale: I18n.default_locale )
      if @webpage.save

        Iox::Activity.create! user_id: current_user.id, obj_name: @webpage.name, action: 'created', icon_class: 'icon-globe', obj_id: @webpage.id, obj_type: @webpage.class.name

        flash.notice = I18n.t('created', name: @webpage.name)
      else
        flash.alert = I18n.t('creation_failed') + ": " + @webpage.errors.full_messages.inspect
      end

      render json: { item: @webpage,
                      errors: @webpage.errors.full_messages,
                      success: @webpage.persisted?,
                      flash: flash }

    end

    #
    # edit a webpage
    #
    def edit
      @webpage = Webpage.where( id: params[:id] ).first
      return if !redirect_if_no_webpage
      @webpage.translation( params[:locale] )
      redirect_if_no_webpage
      redirect_if_no_rights
      render layout: 'application'
    end

    #
    # update a webpage
    #
    def update
      @webpage = Webpage.where( id: params[:id] ).first
      return if !redirect_if_no_webpage
      return if !redirect_if_no_rights
      set_and_save_webpage_translation if params[:webpage] && params[:webpage][:translation]
      save_webbits if params[:webbit]
      save_translations if params[:translation]
      @webpage.set_creator_and_updater( current_user )
      if @webpage.update webpage_params

        Iox::Activity.create! user_id: current_user.id, obj_name: @webpage.name, action: 'edited', icon_class: 'icon-globe', obj_id: @webpage.id, obj_type: @webpage.class.name

        flash.now.notice = I18n.t('saved', name: @webpage.name)
      else
        flash.now.alert = t('saving_failed', name: @webpage)
      end
      render json: { flash: flash }
    end

    #
    # reorder webpage and siblings
    #
    def reorder
      @webpage = Webpage.where( id: params[:id] ).first
      return if !redirect_if_no_webpage
      return if !redirect_if_no_rights
      @webpage.parent_id = params[:parent].blank? ? nil : params[:parent].to_i
      @errors = []
      @errors << @webpage.name unless @webpage.save
      params[:order].each_with_index do |iid,i|
        page = Webpage.where( id: iid.sub('item_','').to_i ).first
        page.position = i
        @errors << page.name unless page.save
      end
      if @errors.size > 0
        flash.now.alert = t('webpage.reordering_failed', names: @errors.join(', '))
      else
        flash.now.notice = t('webpage.reordering_saved')
      end
      render json: { flash: flash, success: flash[:alert].blank? }
    end

    def destroy
      @webpage = Webpage.where( id: params[:id] ).first
      return if !redirect_if_no_webpage
      return if !redirect_if_no_rights
      if @webpage.delete
        @webpage.children.each{ |c| c.delete }
        flash.now.notice = t('webpage.deleted', name: @webpage.name, id: @webpage.id)
      else
        flash.now.alert = t('webpage.failed_to_delete', name: @webpage.name)
      end
      if request.xhr?
        render json: { flash: flash, success: flash[:alert].blank? }
      else
        redirect_to webpages_path
      end
    end

    def restore
      @webpage = Webpage.unscoped.where( id: params[:id] ).first
      return if !redirect_if_no_webpage
      return if !redirect_if_no_rights
      if @webpage.restore
        flash.now.notice = t('webpage.restored', name: @webpage.name)
      else
        flash.now.alert = t('webpage.failed_to_restore', name: @webpage.name)
      end
    end

    private

    def webpage_params
      params.require(:webpage).permit(
        :name, 
        :slug, 
        :template, 
        :parent_id, 
        :show_in_menu,
        :show_in_sitemap,
        :webpage_translation => [ :locale, :meta_keywords, :content ]
      )
    end

    def set_and_save_webpage_translation
      t = nil
      unless trans_params[:id].blank?
        t = @webpage.translations.where( id: trans_params[:id] ).first
        t.updater = current_user
        return t.update( trans_params )
      else
        t = @webpage.translations.build( trans_params )
        t.creator = current_user
      end
      t.updater = current_user
      t.save
    end

    def save_webbits
      webbit_params.each_pair do |id,p|
        next if p[:global]
        webbit = Webbit.where(id: id).first
        unless webbit.update p
          flash.alert = "could not update webbit #{webbit.name}"
        end
      end
    end

    def save_translations
      translation_params.each_pair do |id,t|
        translation = Translation.where(id: id).first
        unless translation.update t
          flash.alert = "could not update webbit #{translation.id} #{translation.locale}"
        end
      end
    end

    def webbit_params
      params.require('webbit')
    end

    def translation_params
      params.require('translation')
    end

    def trans_params
      params.require(:webpage).require(:translation).permit(
        :id,
        :locale,
        :meta_keywords,
        :content,
        :meta_description
        )
    end

    def init_webpage_translation
      return unless @webpage
      @webpage.translation( params[:locale] )
    end

    def update_stat

      return unless @webpage

      if day_stat = @webpage.stats.where( day: Time.now.to_date, ip_addr: request.remote_ip.to_s, user_agent: request.env["HTTP_USER_AGENT"].to_s ).first
        day_stat.views += 1
        if day_stat.updated_at < 30.minutes.ago
          day_stat.visits += 1
        end
        day_stat.save!
      else
        @webpage.stats.create!( ip_addr: request.remote_ip.to_s, day: Time.now.to_date, user_agent: request.env["HTTP_USER_AGENT"].to_s )
      end

    end

  end

end
