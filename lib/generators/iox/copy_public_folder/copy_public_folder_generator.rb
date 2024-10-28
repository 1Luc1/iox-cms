require 'rails/generators/migration'

module Iox
  module Generators
    class CopyPublicFolderGenerator < Rails::Generators::Base

      source_root File.expand_path('../templates', __FILE__)

      desc "Copy public folder files"

      def setup_and_create    
        directory "images", "public/images"
      end
    end
  end
end
