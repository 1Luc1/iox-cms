namespace :iox do

  desc "update quotas in your application's config file"
  task :update_quota => :environment do
    quota_yml_filename = File::join( Rails.root, '/config/iox_quota.yml' )
    if File.exists?( quota_yml_filename )
      res = %x( du -cb #{Rails.root}/public | /bin/grep total )
      quota = { cur: res.split(' ')[0].strip.to_i }
      begin
        res = %x( du -cb #{Iox::CloudContainer.get_cloud_storage_path} | /bin/grep total )
        quota = { cur: (quota[:cur] + res.split(' ')[0].strip.to_i) }
        puts "[iox] cloud usage: #{res.split(' ')[0].strip.to_i}"
      rescue NameError => e
        puts "[iox] skipped cloud usage"
      end
      puts "[iox] QUOTA: Set to #{quota}"
      File.write( quota_yml_filename, quota.to_yaml)
    else
      puts "[iox] QUOTA: ERROR could not find #{quota_yml_filename}"
    end
  end

end