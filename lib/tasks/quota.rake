namespace :iox do

  desc "update quotas in your application's config file"
  task :update_quota do
    quota_yml_filename = File::join( Rails.root, '/config/iox_quota.yml' )
    if File.exists?( quota_yml_filename )
      res = %x( du -cb | /bin/grep total )
      quota = { cur: res.split(' ')[0].strip.to_i }
      puts "[iox] QUOTA: Set to #{quota}"
      File.write( quota_yml_filename, quota.to_yaml)
    else
      puts "[iox] QUOTA: ERROR could not find #{quota_yml_filename}"
    end
  end

end