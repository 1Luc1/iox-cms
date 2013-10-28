module Iox
  class Blog < Webpage

    def as_json(options = { })
      h = super(options)
      h[:creator_name] = creator ? creator.full_name : ''
      h[:translation] = translation
      h[:type] = type
      h
    end

  end
end