module Iox
  class Translation < ActiveRecord::Base

    belongs_to :webbit, inverse_of: :translations
    belongs_to :webpage, inverse_of: :translations

    belongs_to :localeable, polymorphic: true

    belongs_to :creator, class_name: 'Iox::User', foreign_key: :created_by
    belongs_to :updater, class_name: 'Iox::User', foreign_key: :updated_by
    belongs_to :deletor, class_name: 'Iox::User', foreign_key: :deleted_by


    validates   :meta_keywords, length: { maximum: 255 }
    validates   :meta_description, length: { maximum: 255 }

  end
end
