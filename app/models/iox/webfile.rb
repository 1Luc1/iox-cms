module Iox
  class Webfile < ActiveRecord::Base

    Paperclip.interpolates :webpage_id do |attachment, style|
      attachment.instance.webpage_id
    end

    include Iox::FileObject

    # paperclip plugin
    has_attached_file :file,
                      :styles => Rails.configuration.iox.webfile_sizes,
                      :default_url => "/images/:style/missing.png",
                      :url => "/data/webfiles/:webpage_id/:style/:updated_at_:basename.:extension"

    belongs_to :webpage

  end
end