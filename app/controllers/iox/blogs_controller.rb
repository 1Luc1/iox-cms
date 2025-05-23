require_dependency "iox/application_controller"

module Iox
  class BlogsController < ApplicationController

    include Iox::WebpagesHelper

    before_action :authenticate!, except: [ :list, :show, :tags ]

    #
    # list all blogs
    #
    def index
      if request.xhr?
        @num_blogs = Blog.count
        offset = params[:page] || 0
        limit = params[:limit] || 100
        if params[:parent].blank?
          query = "parent_id IS NULL"
        else
          query = "parent_id = '#{params[:parent]}'"
        end
        @blogs = Blog.where( query ).limit( limit ).offset( offset ).order(:position).load.map{ |blog|
          blog.translation = blog.translations.where( locale: params[:locale] || I18n.default_locale ).first
          blog
        }
        render json: { items: @blogs }
      else
        @blog = Blog.new template: 'blog'
        @blog.translation = @blog.translations.build( locale: I18n.default_locale )
      end
    end

    def list
      @page = params[:page].blank? ? 0 : params[:page].to_i
      @tag = params[:tag] || nil
      @blogs = Blog.where(published: true)
      if @tag
        @blogs = @blogs.includes(:translations).references(:iox_translations).where('iox_translations.meta_keywords LIKE ?',"%#{@tag}%")
      end
      @total = @blogs.count
      @blogs = @blogs.limit( 10 ).offset( @page * 10 ).order("iox_webpages.created_at DESC").load
      @webpage = @frontpage = Webpage.where( template: 'frontpage', deleted_at: nil ).first
      render layout: 'application'
    end

    #
    # show form for new blog
    #
    def new
      @blog = Blog.new template: 'blog'
      render json: @blog
    end

    #
    # create new blog
    #
    def create
      @blog = Blog.new blog_params
      @blog.template = 'blog'
      return if !redirect_if_no_rights
      @blog.set_creator_and_updater( current_user )
      if @blog.save

        @blog.translation # just touch translation in order to make it create

        Iox::Activity.create! user_id: current_user.id, obj_name: @blog.name, action: 'created', icon_class: 'icon-rss', obj_id: @blog.id, obj_type: @blog.class.name

        flash.notice = I18n.t('created', name: @blog.name)
      else
        flash.alert = I18n.t('creation_failed') + ": " + @blog.errors.full_messages.inspect
      end

      render json: {
        item: @blog,
        errors: @blog.errors.full_messages,
        success: @blog.persisted?,
        flash: flash }
    end

    # edit blog
    #
    def edit
      @webpage = @blog = Blog.find_by_id( params[:id] )
      @frontpage = Webpage.where( template: 'frontpage', deleted_at: nil ).first
      return if !redirect_if_no_webpage(@blog)
      render layout: 'application'
    end

    #
    # update a blog
    #
    def update
      @blog = Blog.find_by_id( params[:id] )
      return if !redirect_if_no_webpage(@blog)
      return if !redirect_if_no_rights
      set_and_save_webpage_translation(@blog)
      @blog.set_creator_and_updater( current_user )
      if @blog.update blog_params
        Iox::Activity.create! user_id: current_user.id, obj_name: @blog.name, action: 'edited', icon_class: 'icon-globe', obj_id: @blog.id, obj_type: @blog.class.name
        flash.now.notice = I18n.t('saved', name: @blog.name)
      else
        flash.now.alert = t('saving_failed', name: @blog)
      end
      render json: { flash: flash }
    end


    #
    # show this blog
    #
    def show
      @blog = Blog.find_by_id( params[:id] )
      return if !redirect_if_no_webpage(@blog)
      @webpage = @frontpage = Webpage.where( template: 'frontpage', deleted_at: nil ).first
      render layout: 'application'
    end

    private

    def blog_params
      params.require(:blog).permit(
        :name
      )
    end

    def trans_params
      params.require(:blog).require(:translation).permit(
        :id,
        :title,
        :locale,
        :meta_keywords,
        :meta_description,
        :content
      )
    end

  end

end
