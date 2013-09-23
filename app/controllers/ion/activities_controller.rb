module Ion
  class ActivitiesController < ApplicationController

    before_filter :authenticate!

    def summary
      @activities = Ion::Activity.where("created_at > ?", current_user.last_activities_call || 7.days.ago).load
      render layout: false
    end

  end
end
