require_dependency "iox/application_controller"

module Iox
  class AuthController < ApplicationController

    layout 'iox/auth'

    before_filter :authenticate!, except: [ :login, :forgot_password, :unauthenticated, :reset_password, :set_password ]

    #
    # checks if the provided email address matches
    # a user and password. If yes authenticates
    # the user
    def login

      return redirect_to Rails.configuration.iox.redirect_after_login if authenticated?

      if request.post?

        resource = warden.authenticate!( :password )
        if warden.authenticate!

          camefrom = session[:came_from]

          if( current_user.login_failures && current_user.login_failures > 0 )
            flash.now.notice = I18n.t('auth.login_failures', at: I18n.l(current_user.last_login_failure, format: :short), count: current_user.login_failures )
          end

          if Rails.configuration.iox.open_registration && !current_user.registration_completed
            Iox::Activity.create! user_id: current_user.id, obj_name: current_user.username, action: 'first_signup', icon_class: 'icon-user', obj_id: current_user.id, obj_type: current_user.class.name, obj_path: user_path(current_user)
            current_user.registration_completed = true
          end

          current_user.attributes = { last_request_at: Time.now,
                                last_request_ip: request.remote_ip,
                                last_login_ip: request.remote_ip,
                                login_failures: 0,
                                last_login_at: Time.now }
          current_user.save!

          redirect_to ( (camefrom && camefrom != "/login") ? session[:came_from] : Rails.configuration.iox.redirect_after_login )
          session.delete( :came_from )
        end

      end

    end

    #
    # change the user's password
    # returns a html snippet meant to
    # be inserted inside a modal window or simmilar
    #
    def change_password
      @user = Iox::User.find_by_id( params[:id] )
      render layout: false
    end

    # save the given password
    # if passwords don't match,
    # error is thrown by active record
    # validation
    def save_password
      @user = Iox::User.find_by_id( params[:id] )
      @user.password = params[:user][:password]
      @user.password_confirmation = params[:user][:password_confirmation]
      if @user.save
        flash.now.notice = t('auth.password_changed')
      else
        flash.now.alert = @user.errors.first.last
      end
    end

    def forgot_password

      if request.post?
        if u = Iox::User.where( email: params[:email] ).first
          u.gen_confirmation_key
          if u.save
            UserMailer.forgot_password( u ).deliver
            flash.notice = I18n.t('auth.instructions_have_been_sent')
          else
            flash.alert = I18n.t('auth.key_could_not_be_generated')
          end
        else
          flash.alert = I18n.t('auth.email_not_recognized')
        end
      end
    end

    def reset_password
      if @user = User.where( id: params[:id], confirmation_key: params[:k] ).first
        if request.post?
          if params[:password] && params[:password_confirmation] && params[:password] == params[:password_confirmation]
            @user.password = params[:password]
            @user.password_confirmation = params[:password_confirmation]
            if @user.save
              flash.notice = t('auth.new_password_saved')
              redirect_to login_path
            else
              flash.now.alert = @user.errors.first.last
            end
          else
            flash.now.alert = t('auth.passwords_missmatch')
          end
        end
      else
        flash.now.alert = t('auth.invalid_key')
      end
    end

    def set_password
      unless @user = User.where( id: params[:id], confirmation_key: params[:k] ).first
        flash.now.alert = t('auth.invalid_key')
      end
    end

    def unauthenticated
      session[:came_from] = request.original_url
      flash.now.alert = warden.message ? I18n.t(warden.message) : I18n.t('auth.login_failed')
      render template: 'iox/auth/login'
    end

    #
    # loggs off a user and nullifies it's session
    #
    def logout
      warden.logout
      # delete any cookie set by this login session
      cookies.each do |cookie|
        cookies.delete( cookie[0] )
      end
      flash[:notice] = I18n.t('auth.you_have_been_logged_out')
      redirect_to (Rails.configuration.iox.redirect_after_logout || login_path)
    end

  end
end
