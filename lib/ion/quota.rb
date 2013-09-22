module Ion

  module Quota

    def self.read
      @@quota ||= ActiveSupport::HashWithIndifferentAccess.new(
        YAML::load_file( File.join( Rails.root, '/config/ion_quota.yml') )
      )
    end

  end

end