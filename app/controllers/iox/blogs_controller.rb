require_dependency "iox/application_controller"

module Iox
  class BlogsController < ApplicationController

    include Iox::WebpagesHelper

    before_filter :authenticate!, except: [ :list, :show ]

    #
    # list all blogs
    #
    def index
      if request.xhr?
        @num_blogs = Blog.count
        offset = params[:page] || 0
        limit = params[:limit] || 20
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

    #
    # show this blog
    #
    def show
      @blog = Blog.find_by_id( params[:id] )
      render layout: 'application'
    end

    private


    def blog_params
      params.require(:blog).permit(
        :name
      )
    end


  end

end
