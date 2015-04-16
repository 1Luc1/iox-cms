require_dependency "iox/application_controller"

module Iox
  class UsersController < ApplicationController

    before_filter :authenticate!, except: [ :register ]

    #
    # list all users
    #
    def index
      return redirect_401 unless current_user.is_admin?
      return unless request.xhr?
      offset = params[:page] || 0
      limit = params[:limit] || 20
      order = params[:order] || 'lastname ASC, firstname ASC'
      query = params[:query].blank? ? nil : params[:query]
      #suspended = (params[:suspended] && params[:suspended] == 'true')
      # if suspended
      #   @users = User.where(suspended: true)
      # else
      #   @users = User.where(suspended: false)
      # end
      @users = User
      @users = @users.where(" email LIKE ? OR username LIKE ? OR lastname LIKE ? OR firstname LIKE ? ", 
                          "%#{query}%", 
                          "%#{query}%", 
                          "%#{query}%", 
                          "%#{query}%" ) if query
      @users = @users.order(order).load
      render json: { items: @users, query: query }
    end

    def export
      @users = User.all.order(:lastname, :username, :email)
    end

    #
    # show new user form
    #
    def new
      @user = User.new roles: Rails.configuration.iox.user_default_roles.join(','), can_read_apps: Rails.configuration.iox.default_read_apps.join(','), can_write_apps: Rails.configuration.iox.default_write_apps.join(','), send_welcome_msg: true
      render json: @user
    end

    #
    # show registration form
    #
    def register
      redirect_to render_401 unless Rails.configuration.iox.open_registration
      if request.post?
        redirect_to render_401 unless params[:username].blank? # HONEYPOT !!!
        @user = User.new roles: Rails.configuration.iox.user_default_roles, can_read_apps: Rails.configuration.iox.default_read_apps, can_write_apps: Rails.configuration.iox.default_write_apps, send_welcome_msg: true, email: params[:user][:email], confirmation_key_valid_until: 30.minutes.from_now, username: params[:user][:email], registration_ip: request.remote_ip
        if @user.save
          @completed = true

          Iox::Activity.create! user_id: @user.id, obj_name: @user.username, action: 'registered', icon_class: 'icon-user', obj_id: @user.id, obj_type: @user.class.name, obj_path: user_path(@user)

          flash.now.notice = t('user.registration_almost_complete_title')
          UserMailer.registration_welcome_email(@user).deliver
        else
          flash.now.alert = t('user.registration_failed')
        end
      else
        flash.now.notice = t('user.registration_enter_email')
        @user = User.new
      end
      render layout: 'iox/auth'
    end

    #
    # confirm suspend form
    #
    def confirm_suspend
      redirect_to render_404 unless current_user.is_admin?
      @user = User.find_by_id( params[:id] )
      render layout: false
    end

    #
    # suspend user
    #
    def suspend
      return notify_401 unless current_user.is_admin?
      @user = User.find_by_id( params[:id] )
      if current_user.id == @user.id
        return flash.alert = t('user.cannot_suspend_yourself')
      end
      if @user.update( suspended: true )
        flash.now.notice = t('user.suspending_ok', name: @user.username)
      else
        flash.now.alert = t('user.suspending_failed', name: @user.username)
      end
    end

    #
    # unsuspend user
    #
    def unsuspend
      return notify_401 unless current_user.is_admin?
      @user = User.find_by_id( params[:id] )
      if @user.update( suspended: false )
        flash.now.notice = t('user.unsuspending_ok', name: @user.username)
      else
        flash.now.alert = t('user.unsuspending_failed', name: @user.username)
      end
      render template: '/iox/users/suspend'
    end

    # get a confirmation qr
    # code for this user (only for admins)
    def confirmation_qr
      return render_401 unless current_user.is_admin?
      @user = User.find_by_id( params[:id] )
      respond_to do |format|
        format.png  { 
          render :qrcode => "http://#{Rails.configuration.iox.domain_name}/iox/welcome/#{@user.id}?k=#{@user.confirmation_key}", level: :m, offset: 20 
        }
      end
    end

    #
    # create a new user
    #
    def create
      @user = User.new user_params
      if current_user.is_admin?
        @user.roles = params[:roles].join(',')
      else
        @user.roles = 'user'
      end
      if @user.save

        Iox::Activity.create! user_id: current_user.id, obj_name: @user.username, action: 'created', icon_class: 'icon-user', obj_id: @user.id, obj_type: @user.class.name

        if params[:send_welcome_msg]
          UserMailer.welcome_email(@user,current_user).deliver
          flash.now.notice = t('user.created_and_mail_sent', name: @user.username)
        else
          flash.now.notice = t('user.created', name: @user.username)
        end
      else
        if @user.errors.size > 0
          flash.now.alert = @user.errors.first[1]
        else
          flash.now.alert = t('user.creation_failed')
        end
      end
      if request.xhr?
        render json: { item: @user,
                        errors: @user.errors.full_messages,
                        success: @user.persisted?,
                        flash: flash }
      else
        redirect_to login_path
      end
    end

    def settings_for
      @user = User.find_by_id params[:id]
      if @user && ( @user.id == current_user.id || current_user.is_admin? )
        Rails.configuration.iox.user_settings.each_pair do |key,val|
          unless @user.settings.where key: key
            @user.settings.create! key: key, val: val
          end
        end
      end
    end

    #
    # render the users's avatar
    #
    def avatar
    end

    #
    # show the user's profile
    #
    def show
      @user = User.where(:id => params[:id]).first
    end

    #
    # show the user's profile
    #
    def edit
      @user = User.where(:id => params[:id]).first
      return render_401 if @user.id != current_user.id && !current_user.is_admin?
      render layout: false
    end

    #
    # update a user's profile
    #
    def update
      @user = User.where(:id => params[:id].split('-').first).first
      return notify_401 if @user.id != current_user.id && !current_user.is_admin?
      if @user
        if @user.id != current_user.id && !current_user.is_admin?
          flash.alert = I18n.t('error.unsufficient_rights')
          return
        end
        if current_user.is_admin? && params[:roles]
          params[:user][:roles] = params[:roles].join(',')
        else
          params[:user].delete(:roles)
        end
        if params[:user][:avatar]
          @user.avatar = params[:user][:avatar]
        end
        if params[:user][:password].blank? || params[:user][:password_confirmation].blank?
          params[:user].delete(:password)
          params[:user].delete(:password_confirmation)
        end
        if @user.update user_params
          flash.now.notice = I18n.t('user.saved', name: @user.name)
        end
      else
        flash.now.alert = I18n.t('error.object_not_found')
      end
      if request.xhr?
        render json: { item: @user,
                        errors: @user.errors.full_messages,
                        success: @user.persisted?,
                        flash: flash }
      else
        redirect_to user_path( @user )
      end
    end

    #
    # upload avatar
    #
    def upload_avatar
      if @user = User.where(:id => params[:id]).first
        @user.avatar = params[:user][:avatar]
        if @user.save
          render :json => [@user.to_jq_upload('avatar')].to_json
        else
          render :json => [{:error => "custom_failure"}], :status => 304
        end
      end
    end

    #
    # confirm delete form
    #
    def confirm_delete
      redirect_to render_401 unless current_user.is_admin?
      @user = User.find_by_id( params[:id] )
      render layout: false
    end

    #
    # destroy a user
    #
    def destroy
      @user = User.where(:id => params[:id]).first
      return render_401 if !current_user.is_admin? && @user.id != current_user.id
      if !params[:username] || params[:username] != @user.username
        return flash.now.alert = I18n.t('user.delete_entered_username_missmatch', name: @user.username)
      end
      if @user.destroy

        Iox::Activity.create! user_id: current_user.id, obj_name: @user.username, action: 'deleted', icon_class: 'icon-user'

        if params[:delete_content] && params[:delete_content] == "1"
          Iox::registered_models.each do |model|
            model.where(created_by: @user.id).destroy_all
          end
          flash.now.notice = I18n.t('user.deletion_and_content_ok', name: @user.username)
        else
          flash.now.notice = I18n.t('user.deletion_ok', name: @user.username)
        end
      else
        flash.now.alert = I18n.t('user.deletion_failed', name: @user.username)
      end
    end

    private

    def user_params
      params.require(:user).permit(
        :username, 
        :firstname, 
        :lastname, 
        :email, 
        :password, 
        :password_confirmation, 
        :lang, 
        :roles, 
        :can_read_apps, 
        :can_write_apps, 
        :send_welcome_msg, 
        :suspended, 
        :phone,
        :registration_completed )
    end

  end
end
