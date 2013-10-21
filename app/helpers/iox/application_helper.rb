module Iox

  module ApplicationHelper

    def flash_with_javascript
      message = flash.alert || flash.notice
      if message
        type = flash.keys[0].to_s
        javascript_tag %Q{ iox.flash["#{type}"]("#{message}"); }
      end
    end

    def get_ordered_plugins
      plugins = []
      if Rails.configuration.iox.plugin_order
        Rails.configuration.iox.plugin_order.each do |plugin_o|
          Rails.configuration.iox.plugins.each do |plugin|
            plugins << plugin if plugin.name == plugin_o
          end
        end
        return plugins
      end
      Rails.configuration.iox.plugins
    end

    def can_write_plugin?( plugin_name=controller.controller_name )
      Rails.configuration.iox.plugins.each do |plugin|
        if plugin.name == plugin_name
          return !(Set.new(plugin.roles) & Set.new(current_user.roles)).empty?
        end
      end
      false
    end

  end

end