require 'rails/generators/migration'

module Iox
  module Generators
    class CopyPublicFolderGenerator < Rails::Generators::Base

      source_root File.expand_path('../../install/templates', __FILE__)

      desc "Copy public folder files"

      def setup_and_create    
        directory "webfonts", "public/webfonts"
        directory "javascripts", "public/javascripts/3rdparty/"
        directory "avatar", "public/images/iox/avatar"
        directory "kendoui", "public/stylesheets/3rdparty/kendoui"
      end
    end
  end
end
