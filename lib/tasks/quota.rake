namespace :ion do

  desc "update quotas in your application's config file"
  task :update_quota do
    quota_yml_filename = File::join( Rails.root, '/config/ion_quota.yml' )
    if File.exists?( quota_yml_filename )
      res = %x( du -c | grep total )
      quota = { cur: res.split(' ')[0].strip.to_i }
      puts "[ion] QUOTA: Set to #{quota}"
      File.write( quota_yml_filename, quota.to_yaml)
    else
      puts "[ion] QUOTA: ERROR could not find #{quota_yml_filename}"
    end
  end

end