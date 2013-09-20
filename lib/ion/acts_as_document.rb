# encoding: utf-8
require 'digest/sha2'

module Ion
  module ActsAsDocument

    extend ActiveSupport::Concern

    included do
    end

    module ClassMethods
      def acts_as_ion_document(options = {})

        include InstanceMethods

        default_scope { where(deleted_at: nil) }

      end
    end

    module InstanceMethods

      def set_creator_and_updater( user )
        if new_record?
          self.creator = user
        end
        self.updater = user
      end

      def delete
        self.deleted_at = Time.now
        self.save
      end

      def restore
        self.deleted_at = nil
        self.save
      end

      def create_slug( name=name )
        #strip the string
        ret = name.strip

        #blow away apostrophes
        ret.gsub! /['`]/,""

        # @ --> at, and & --> and
        ret.gsub! /\s*@\s*/, " at "
        ret.gsub! /\s*&\s*/, " and "

        ret.gsub!(/[äöüß]/) do |match|
          case match
            when "ä" then 'ae'
            when "ö" then 'oe'
            when "ü" then 'ue'
            when "ß" then 'ss'
          end
        end

        #replace all non alphanumeric, underscore or periods with underscore
        ret.gsub! /\s*[^A-Za-z0-9\.\-]\s*/, '_'

        #convert double underscores to single
        ret.gsub! /_+/,"_"

        #strip off leading/trailing underscore
        ret.gsub! /\A[_\.]+|[_\.]+\z/,""

        self.slug = ret.downcase

      end

    end

  end
end

ActiveRecord::Base.send :include, Ion::ActsAsDocument