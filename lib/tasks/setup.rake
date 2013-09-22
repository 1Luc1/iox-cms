require File::expand_path '../rake-colors', __FILE__

namespace :ion do

  desc "setup admin account"
  task :setup => :environment do

    include Colors

    email = "admin@#{Rails.configuration.ion.domain_name}"
    password = "mgr"
    puts "[ion] email #{green email} pass #{green password}"

    @user = Ion::User.new username: 'manager', email: email, roles: 'admin,editor,user', password: password, password_confirmation: password
    if @user.valid? && @user.save
      puts "[ion] successfully created user manager"
    else
      puts "[ion]#{red " ERROR"} user #{red @user.username} already exists"
    end

  end

end
