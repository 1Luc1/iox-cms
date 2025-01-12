require_dependency "iox/application_controller"

module Iox
  class DashboardController < ApplicationController

    before_action :authenticate!

    def index
    end

    def quota
      @quota_cur = Iox::Quota::read
      @quota_cur = @quota_cur[:cur] if @quota_cur.has_key?(:cur)
      @quota_cur = 0 unless @quota_cur.is_a?(Integer)
      @quota_max = Rails.configuration.iox.max_quota_mb
      render layout: false
    end

  end
end
