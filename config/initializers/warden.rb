require 'rails_warden'

Rails.configuration.middleware.use RailsWarden::Manager do |manager|
  manager.default_strategies :password
  manager.failure_app = Iox::AuthController
end

# Setup Session Serialization
#class Warden::SessionSerializer
#  def serialize(record)
#    [record.class.name, record.id]
#  end
#
#  def deserialize(keys)
#    klass, id = keys
#    klass.find(:first, :conditions => { :id => id })
#  end
# end


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
    u = Iox::User.where( "email = '#{params[:email]}' OR username = '#{params[:email]}' ").first.try(:authenticate, params[:password] )
    if u.nil?
      session[:came_from] ||= request.referer
      return fail!('auth.login_failed')
    else
      success!(u)
    end
  end

end
