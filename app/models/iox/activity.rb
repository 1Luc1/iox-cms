module Iox

  class Activity < ActiveRecord::Base

    belongs_to :user

    def obj
      eval("#{obj_type}").find_by_id(obj_id)
    end

  end

end