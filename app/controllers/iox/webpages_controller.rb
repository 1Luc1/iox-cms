require_dependency "iox/application_controller"

module Iox
  class WebpagesController < ApplicationController

    include Iox::WebpagesHelper
    include Iox::WebpageStats

    before_action :authenticate!, except: [ :frontpage, :show, :by_slug ]

    #
    # shows the frontpage
    # the frontpage is of template type 'frontpage' and there should
    # only be one
    def frontpage
      @webpage = @frontpage = Webpage.where( template: 'frontpage', deleted_at: nil ).first
      setup_webpage_locale
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
        if params[:query].blank?
          if params[:parent].blank?
            query = "parent_id IS NULL"
          else
            query = "parent_id = '#{params[:parent]}'"
          end
          @webpages = Webpage.where( query )
        else
          @webpages = Webpage.where("name LIKE ?", "%#{params[:query]}%")
        end
        @webpages = @webpages.where(type: nil).order(:position).load.map{ |webpage|
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
      setup_webpage_locale
      @webpage.parent_id = params[:parent] unless params[:parent].blank?
      @parent = @webpage.parent if( @webpage.parent_id )
      render json: @webpage
    end

    #
    # show this webpage
    #
    def show
      @webpage = Webpage.find_by_id( params[:id] )
      setup_webpage_locale
      @frontpage = Webpage.where(template: 'frontpage').first
      init_webpage_translation
      return if !redirect_if_no_webpage
      update_stat
      render layout: 'application'
    end

    def by_slug
      @webpage = Webpage.where( slug: params[:slug] ).first
      setup_webpage_locale
      @frontpage = Webpage.where(template: 'frontpage').first
      setup_webpage_locale( @frontpage )
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
      if @webpage.save

        @webpage.translation # just touch translation in order to make it create

        Iox::Activity.create! user_id: current_user.id, obj_name: @webpage.name, action: 'created', icon_class: 'icon-globe', obj_id: @webpage.id, obj_type: @webpage.class.name

        flash.notice = I18n.t('created', name: @webpage.name)
      else
        flash.alert = I18n.t('creation_failed') + ": " + @webpage.errors.full_messages.inspect
      end

      render json: {
        item: @webpage,
                      errors: @webpage.errors.full_messages,
                      success: @webpage.persisted?,
                      flash: flash }

    end

    #
    # edit a webpage
    #
    def edit
      @webpage = Webpage.where( id: params[:id] ).first
      @frontpage = Webpage.where(template: 'frontpage').first
      setup_webpage_locale
      setup_webpage_locale( @frontpage )
      return if !redirect_if_no_webpage
      @webpage.translation
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
      params[:webpage]
      params.require(:webpage).permit( Iox::Webpage::allowed_attrs )
    end

    def save_webbits
      webbit_params.each_pair do |id,p|
        next if p[:global]
        if webbit = Webbit.where(id: id).first
          unless webbit.update p.permit(:id, :name, :category, :css_classes, :position, :plugin_type)
            flash.now.alert = "could not update webbit #{webbit.name}"
          end
        else
          flash.now.alert = t('webbit.not_found')
        end
      end
    end

    def save_translations
      translation_params.each_pair do |id,t|
        translation = Translation.where(id: id).first
        unless translation.update t.permit(:name, :content, :id, :locale, :translation)
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
      @webpage.translation
    end

    def setup_webpage_locale(webpage=@webpage)
      return unless webpage
      webpage.locale = params[:locale] || I18n.locale
      webpage.webbits.each{ |wb| wb.locale = webpage.locale }
    end

  end

end
