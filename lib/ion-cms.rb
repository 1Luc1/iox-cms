module Ion
  @@registered_models ||= []

  def self.register_model( obj )
    @@registered_models << obj
  end

  def self.registered_models
    @@registered_models
  end
end

require "ion/version"
require "ion/enable_config_namespace"
require "ion/engine"
require "ion/file_object"
require "ion/acts_as_document"

require "ion/quota"

require "ion/plugin"

# authentication and warden integration
require 'ion/controller_helpers'

# require all gem files
require 'paperclip'
