module Iox

  module FileObject

    #one convenient method to pass jq_upload the necessary information
    def to_jq_upload(name)
      ret = {
        "id" => instance_eval("#{id}"),
        "original_name" => instance_eval("#{name}_file_name"),
        "name" => instance_eval("self.name"),
        "size" => instance_eval("#{name}_file_size"),
        "url" => instance_eval("#{name}.url"),
        "content_type" => instance_eval("#{name}.content_type"),
        "thumbnail_url" => instance_eval("#{name}.url(:thumb)"),
        "thumb_url" => instance_eval("#{name}.url(:thumb)"),
        "original_url" => instance_eval("#{name}.url(:original)"),
        "updated_at" => instance_eval("updated_at"),
        "updater_name" => instance_eval("updater ? updater.full_name : ''")
      }
      ret["description"] = description if defined?(description)
      ret["copyright"] = copyright if defined?(copyright)
      ret
    end

  end

end