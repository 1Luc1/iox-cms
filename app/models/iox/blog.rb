module Iox
  class Blog < Webpage

    def as_json(options = { })
      h = super(options)
      h[:translation] = translation
      h[:creator_name] = creator.full_name
      h[:type] = type
      h
    end

  end
end