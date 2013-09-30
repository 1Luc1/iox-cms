module Iox

  module Quota

    def self.read
      ActiveSupport::HashWithIndifferentAccess.new(
        YAML::load_file( File.join( Rails.root, '/config/iox_quota.yml') )
      )
    end

  end

end