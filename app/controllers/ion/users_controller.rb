module Ion
  class UsersController < ApplicationController

    before_filter :authenticate!

    #
    # list all users
    #
    def index
      @users = User.order(lastname: :asc, firstname: :asc).load
    end

    #
    # show new user form
    #
    def new
      @user = User.new roles: Rails.configuration.ion.user_default_roles.join(','), can_read_apps: Rails.configuration.ion.default_read_apps.join(','), can_write_apps: Rails.configuration.ion.default_write_apps.join(','), send_welcome_msg: true
    end

    #
    # show registration form
    #
    def register
      if request.post?
        puts "register"
      else
        @user = User.new roles: Rails.configuration.ion.user_default_roles, can_read_apps: Rails.configuration.ion.default_read_apps, can_write_apps: Rails.configuration.ion.default_write_apps, send_welcome_msg: true
      end
    end

    #
    # create a new user
    #
    def create
      @user = User.new user_params

      @user.attributes = user_params

      if @user.save
        UserMailer.welcome_email(@user,current_user).deliver if @user.send_welcome_msg == '1'
        flash.notice = t('user.created', name: @user.username)
        redirect_to users_path
      else
        render template: 'ion/users/new'
      end
    end

    def settings_for
      @user = User.find_by_id params[:id]
      if @user && ( @user.id == current_user.id || current_user.is_admin? )
        Rails.configuration.ion.user_settings.each_pair do |key,val|
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
      flash.notice = I18n.t('user.you_are_admin_and_can_edit') if current_user.is_admin?
      #@wide_content = true
      @user = User.where(:id => params[:id]).first
      render template: 'ion/users/edit'
    end

    #
    # update a user's profile
    #
    def update
      @wide_content = true
      if @user = User.where(:id => params[:id]).first
        if @user.id != current_user.id && !current_user.is_admin?
          flash.alert = I18n.t('error.unsufficient_rights')
          return
        end
        if params[:user][:avatar]
          @user.avatar = params[:user][:avatar]
        end
        if params[:user][:password].blank? || params[:user][:password_confirmation].blank?
          params[:user].delete(:password)
          params[:user].delete(:password_confirmation)
        end
        if @user.update(user_params)
          flash.notice = I18n.t('changes_have_been_saved')
        end
      else
        flash.alert = I18n.t('error.object_not_found')
      end
      redirect_to @user
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

    private

    def user_params
      params.require(:user).permit(:username, :firstname, :lastname, :email, :password, :password_confirmation, :lang, :roles, :can_read_apps, :can_write_apps, :send_welcome_msg)
    end

  end
end
