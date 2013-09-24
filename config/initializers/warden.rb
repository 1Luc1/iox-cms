require 'rails_warden'

Rails.configuration.middleware.use RailsWarden::Manager do |manager|
  manager.default_strategies :password #, :basic
  manager.failure_app = Iox::AuthController
end

Warden::Manager.serialize_into_session do |user|
  user.id
end

Warden::Manager.serialize_from_session do |id|
  Iox::User.where(id: id).first
end

Warden::Strategies.add(:password) do

  def valid?
    params[:username] || params[:password]
  end

  def authenticate!
    if u = Iox::User.where( "email = '#{params[:email]}' OR username = '#{params[:email]}' ").first.try(:authenticate, params[:password] )
      return success!(u)
    else
      if x = Iox::User.where( "email = '#{params[:email]}' OR username = '#{params[:email]}' ").first
        x.update!( login_failures: ( x.login_failures ? x.login_failures+1 : 1), last_login_failure: Time.now )
      end
      session[:came_from] ||= request.referer
      return fail!('auth.login_failed')
    end
  end

end
