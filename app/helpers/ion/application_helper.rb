module Ion

  module ApplicationHelper

    def flash_with_javascript
      message = flash.alert || flash.notice
      if message
        type = flash.keys[0].to_s
        javascript_tag %Q{ ion.flash({ message:"#{message}", type:"#{type}" }); }
      end
    end

    def get_ordered_plugins
      plugins = []
      if Rails.configuration.ion.plugin_order
        Rails.configuration.ion.plugin_order.each do |plugin_o|
          Rails.configuration.ion.plugins.each do |plugin|
            plugins << plugin if plugin.name == plugin_o
          end
        end
        return plugins
      end
      Rails.configuration.ion.plugins
    end

  end

end