module Ion

  module FileObject

    #one convenient method to pass jq_upload the necessary information
    def to_jq_upload(name)
      ret = {
        "id" => instance_eval("#{id}"),
        "name" => instance_eval("#{name}_file_name"),
        "size" => instance_eval("#{name}_file_size"),
        "url" => instance_eval("#{name}.url"),
        "content_type" => instance_eval("#{name}.content_type"),
        "thumbnail_url" => instance_eval("#{name}.url(:thumb)")
      }
      ret["description"] = description if defined?(description)
      ret["copyright"] = copyright if defined?(copyright)
      ret
    end

  end

end