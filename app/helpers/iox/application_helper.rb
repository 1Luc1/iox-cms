module Iox

  module ApplicationHelper

    def flash_with_javascript
      message = flash.alert || flash.notice
      if message
        type = flash.keys[0].to_s
        javascript_tag %Q{ iox.flash({ message:"#{message}", type:"#{type}" }); }
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

  end

end