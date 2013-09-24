module Ion
  class ActivitiesController < ApplicationController

    before_filter :authenticate!

    def index
      @activities = Ion::Activity.order("created_at DESC").limit(30).load
      current_user.last_activities_call = Time.now
      current_user.save
    end

    def summary
      @activities = Ion::Activity.where("created_at > ?", current_user.last_activities_call || 7.days.ago).load
      current_user.last_activities_call = Time.now
      current_user.save
      render layout: false
    end

  end
end
