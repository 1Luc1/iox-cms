require_dependency "ion/application_controller"

module Ion
  class AuthController < ApplicationController

    layout 'ion/auth'

    before_filter :authenticate!, except: [ :login, :forgot_password, :unauthenticated, :reset_password, :set_password ]

    #
    # checks if the provided email address matches
    # a user and password. If yes authenticates
    # the user
    def login

      return redirect_to Rails.configuration.ion.redirect_after_login if authenticated?

      if request.post?

        resource = warden.authenticate!( :password )
        if warden.authenticate!

          camefrom = session[:came_from]

          if( current_user.login_failures && current_user.login_failures > 0 )
            flash.notice = I18n.t('auth.login_failures', at: current_user.last_login_failure, count: I18n.l(current_user.login_failures, format: :short) )
          end

          current_user.update!( last_request_at: Time.now,
                                last_request_ip: request.remote_ip,
                                last_login_ip: request.remote_ip,
                                login_failures: 0,
                                last_login_at: Time.now )
          redirect_to ( (camefrom && camefrom != "/login") ? session[:came_from] : Rails.configuration.ion.redirect_after_login )
        end

      end

    end

    #
    # change the user's password
    # returns a html snippet meant to
    # be inserted inside a modal window or simmilar
    #
    def change_password
      @user = Ion::User.find_by_id( params[:id] )
      render layout: false
    end

    # save the given password
    # if passwords don't match,
    # error is thrown by active record
    # validation
    def save_password
      @user = Ion::User.find_by_id( params[:id] )
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
        if u = Ion::User.where( email: params[:email] ).first
          u.gen_confirmation_key
          puts "confirmation key: #{u.confirmation_key}"
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

    def unauthenticated
      flash[:alert] = warden.message ? I18n.t(warden.message) : I18n.t('auth.login_failed')
      render template: 'ion/auth/login'
    end

    #
    # loggs off a user and nullifies it's session
    #
    def logout
      warden.logout
      flash[:notice] = I18n.t('auth.you_have_been_logged_out')
      redirect_to login_path
    end

  end
end
