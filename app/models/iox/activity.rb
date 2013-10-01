module Iox

  class Activity < ActiveRecord::Base

    belongs_to :user

    after_save :cleanup_30_days

    def obj
      eval("#{obj_type}").find_by_id(obj_id)
    end

    private

    #
    # cleanup any activity log
    # which is older than 30 days
    def cleanup_30_days
      self.class.where("created_at < ?", 30.days.ago).delete_all
    end

  end

end