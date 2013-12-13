module Iox

  class Domain < ActiveRecord::Base

    include Iox::FileObject

    # paperclip plugin
    has_attached_file :avatar, :styles => { :original => "256x256#", :thumb => "32x32#" },
                      :default_url => "/images/iox/avatar/:style/missing.png",
                      :url => "/data/avatars/:hash.:extension",
                      :hash_secret => "5b1b59b59b08dfea721470feed062327909b8f91"


    has_many          :users

    validates_attachment_content_type :avatar, content_type: [ "image/jpeg", "image/png", "image/jpg" ]

    validates :name, presence: true, uniqueness: true

    before_create :gen_auth_token

    def to_param
      [id, name.parameterize].join("-")
    end

    def as_json(options = { })
      h = super(options)
      h
    end

    def gen_auth_token
      self.auth_token = Digest::SHA256::hexdigest( Time.now.to_f.to_s )
    end

  end

end
