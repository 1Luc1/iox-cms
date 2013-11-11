module Iox
  @@registered_models ||= []

  def self.register_model( obj )
    @@registered_models << obj
  end

  def self.registered_models
    @@registered_models
  end
end

require "iox/version"
require "iox/enable_config_namespace"
require "iox/engine"
require "iox/file_object"
require "iox/acts_as_document"

require "iox/quota"

require "iox/plugin"

# authentication and warden integration
require 'iox/controller_helpers'
require 'iox/access_controller_helpers'
require 'iox/country_select_helpers'

# require all gem files
require 'paperclip'
require 'select2-rails'

# exception_notifier middleware
require 'iox/exception_notifier/exception_notifier'
