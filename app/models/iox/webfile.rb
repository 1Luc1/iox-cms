require_dependency 'iox/file_object'

module Iox
  class Webfile < ActiveRecord::Base

    acts_as_iox_document

    include Iox::FileObject

    Paperclip.interpolates :webpage_id do |attachment, style|
      attachment.instance.webpage_id
    end

    # paperclip plugin
    has_attached_file :file,
                      :styles => Rails.configuration.iox.webfile_sizes,
                      :default_url => "/images/:style/missing.png",
                      :url => "/data/webfiles/:webpage_id/:style/:updated_at_:basename.:extension"

    validates_attachment :file #, content_type: { content_type: ["application/pdf", "image/jpg", "image/png", "image/jpeg", 'application/mp3', 'application/x-mp3', 'audio/mpeg', 'audio/mp3', 'video/mp4', 'video/quicktime', 'video/x-quicktime'] }

    before_post_process :skip_for_audio

    def skip_for_audio
      ! %w(application/mp3 application/x-mp3 audio/mpeg audio/mp3 audio/ogg application/ogg video/mp4 video/quicktime video/x-quicktime).include?(file_content_type)
    end

    belongs_to :webpage

    def as_json(options = { })
      h = super(options)
      thmb = nil
      if file && !file.content_type.blank?
        if file.content_type.include? 'image'
          thmb = file.url(:thumb)
        elsif file.content_type == 'application/pdf'
          thmb = file.url(:pdf_thumb)
        end
      end
      h[:file] = file
      h[:size] = file.size ? file.size / 1000.0 : 0.0
      h[:thumb_url] = thmb
      h[:original_url] = file.url(:original)
      h[:updater_name] = updater ? updater.full_name : '?'
      h
    end

  end
end
