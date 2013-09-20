require "ion/version"

require "ion/config"
require "ion/engine"
require "ion/file_object"
require "ion/acts_as_document"

# authentication and warden integration
require 'ion/controller_helpers'

module Ion

  public

  def self.addons
    @addons ||= []
  end

  def self.register_addon( addon )
    return if Rails.configuration.ion.deny_apps && Rails.configuration.ion.deny_apps.include?( addon[:name] )
    @addons ||= []
    @addons << addon
    Ion::order_addons
  end

  def self.order_addons
    tmp_addons = @addons
    done = []
    @addons = []
    Rails.configuration.ion.addons_order.each do |ao_name|
      tmp_addons.each do |tao|
        if tao[:name] == ao_name
          @addons << tao
          done << ao_name
        end
      end
    end

    # and add all other at the end
    tmp_addons.each do |tao|
      @addons << tao unless done.include?(tao[:name])
    end

  end

end
