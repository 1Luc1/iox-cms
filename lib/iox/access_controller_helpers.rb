module Iox
  module AccessControllerHelpers
    extend ActiveSupport::Concern

    included do
      helper_method :can_write_plugin?
    end

    def redirect_if_no_app_access( write = false )
      if( write )
        redirect dashboard_path unless can_write_plugin?
      else
        redirect dashboard_path unless can_read_plugin?
      end
    end

    def redirect_if_not_owner( obj )
      if current_user.is_admin? || obj.created_by == current_user.id
        return false
      end
      redirect dashboard_path
      true
    end

    def can_write_plugin?( plugin_name=self.class.name.underscore.demodulize.pluralize )
      return true if current_user.is_admin?
      Rails.configuration.iox.plugins.each do |plugin|
        if plugin.name == plugin_name
          return true if current_user.can_write_plugin.include?( plugin_name )
          return true if !(Set.new(plugin.roles) & Set.new(current_user.roles)).empty?
        end
      end
      false
    end

    def can_read_plugin?( plugin_name=self.class.name.underscore.demodulize.pluralize )
      return true if current_user.is_admin?
      Rails.configuration.iox.plugins.each do |plugin|
        if plugin.name == plugin_name
          return true if current_user.can_read_plugin.include?( plugin_name )
          return true if !(Set.new(plugin.roles) & Set.new(current_user.roles)).empty?
        end
      end
      false
    end

  end
end