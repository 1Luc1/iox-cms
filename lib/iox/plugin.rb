module Iox
  class Plugin

    def initialize( attrs )
      attrs.each_pair do |key,val|
        instance_variable_set('@' + key.to_s, val)
      end
    end

    attr_accessor :name
    attr_accessor :roles
    attr_accessor :icon
    attr_accessor :path

  end
end