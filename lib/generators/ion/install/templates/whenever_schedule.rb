every 30.minutes do
  rake "ion:update_quota"
end

set :output, 'log/schedule.log'