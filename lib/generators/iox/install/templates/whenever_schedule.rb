every 30.minutes do
  rake "ion:update_quota"
end

every :day do
  rake "iox:backup_db"
end

set :output, 'log/schedule.log'