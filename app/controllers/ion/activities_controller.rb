module Ion
  class ActivitiesController < ApplicationController

    before_filter :authenticate!

    def summary
      render layout: false
    end

  end
end
