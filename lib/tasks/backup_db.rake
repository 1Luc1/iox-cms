namespace :iox do

  desc "backup the database"
  task :backup_db do
    dbSettings = YAML.load_file( File::join( Rails.root, 'config', 'database.yml' ) )['production']
    filename = "#{Pathname.new(File::join(Rails.root, '..', 'bak')).cleanpath}/#{Time.now.strftime('%Y-%m-%d_%Hh%m')}_#{dbSettings['database']}.sqldump"
    puts "[iox] Starting SQL Backup #{filename}"
    system "mysqldump --user=#{dbSettings['username']} --password=#{dbSettings['password']} #{dbSettings['database']} > #{filename}"
  end

end