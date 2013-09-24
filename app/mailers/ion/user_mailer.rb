module Ion
  class UserMailer < ActionMailer::Base

    # default_from is defined in the config/application.rb file

    def welcome_email(user, creator)
      @user = user
      @creator = creator
      @url  = "http://#{Rails.configuration.ion.domain_name}/ion/welcome/#{user.id}?k=#{user.confirmation_key}"
      @support_email = Rails.configuration.ion.support_email
      @site_title = Rails.configuration.ion.site_name
      mail( to: @user.email, subject: "[#{Rails.configuration.ion.site_name}] #{I18n.t('user.mailer.welcome')}" )
    end

    def confirmation_email(user)
      @user = user
      @url  = "http://#{Rails.configuration.ion.domain_name}/ion/confirm/#{user.confirmation_key}"
      mail( to: @user.email, subject: "[#{Rails.configuration.ion.site_name}] #{I18n.t('user.mailer.welcome')}" )
    end

    def forgot_password(user)
      @user = user
      @url = "http://#{Rails.configuration.ion.domain_name}/ion/reset_password/#{user.id}?k=#{user.confirmation_key}"
      mail( to: @user.email, subject: "[#{Rails.configuration.ion.site_name}] #{I18n.t('auth.forgot_password_request')}" )
    end

  end
end
