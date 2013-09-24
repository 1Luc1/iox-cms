module Ion
  class Translation < ActiveRecord::Base

    belongs_to :webbit, inverse_of: :translations
    belongs_to :webpage, inverse_of: :translations

    belongs_to :creator, class_name: 'Iox::User', foreign_key: :created_by
    belongs_to :updater, class_name: 'Iox::User', foreign_key: :updated_by
    belongs_to :deletor, class_name: 'Iox::User', foreign_key: :deleted_by

  end
end
