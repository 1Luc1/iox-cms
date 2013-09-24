require File::expand_path '../rake-colors', __FILE__

namespace :iox do

  desc "setup admin account"
  task :setup => :environment do

    include Colors

    email = "manager@#{Rails.configuration.iox.domain_name}"
    password = "mgr"
    puts "[iox] email #{green email} pass #{green password}"

    @user = Iox::User.new username: 'manager', email: email, roles: 'admin,editor,user', password: password, password_confirmation: password
    if @user.valid? && @user.save
      puts "[iox] successfully created user manager"
    else
      puts "[iox]#{red " ERROR"} user #{red @user.username} already exists"
    end

  end

end
