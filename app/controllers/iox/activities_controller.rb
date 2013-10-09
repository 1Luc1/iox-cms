module Iox
  class ActivitiesController < ApplicationController

    before_filter :authenticate!

    def index
      @activities = Iox::Activity.where("user_id != ?", current_user.id).order("created_at DESC").limit(30).load
      Iox::Activity.where("created_at < ?", 7.days.from_now).delete_all
      current_user.last_activities_call = Time.now
      current_user.save
    end

    def summary
      @activities = Iox::Activity.where("user_id != ?", current_user.id).where("created_at > ?", current_user.last_activities_call || current_user.last_login_at ).load
      current_user.last_activities_call = Time.now
      current_user.save
      render layout: false
    end

  end
end
