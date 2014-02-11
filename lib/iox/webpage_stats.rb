module Iox

  module WebpageStats

    include ActionView::Helpers::TextHelper

    def update_stat

      return unless @webpage

      if day_stat = @webpage.stats.where( day: Time.now.to_date, ip_addr: request.remote_ip.to_s, user_agent: request.env["HTTP_USER_AGENT"].to_s ).first
        day_stat.views += 1
        if day_stat.updated_at < 30.minutes.ago
          day_stat.visits += 1
        end
        day_stat.save!
      else
        @webpage.stats.create!( ip_addr: request.remote_ip.to_s, 
                                day: Time.now.to_date, 
                                user_agent: truncate( request.env["HTTP_USER_AGENT"].to_s, length: 200 ) )
      end

    end


  end

end