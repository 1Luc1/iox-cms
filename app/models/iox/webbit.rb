module Iox
  class Webbit < ActiveRecord::Base

    acts_as_iox_document

    attr_accessor :lang, :webbit_translation, :global

    has_many :translations, dependent: :delete_all
    has_many :children, class_name: 'Iox::Webbit', dependent: :destroy, foreign_key: :parent_id

    accepts_nested_attributes_for :translations

    def as_json(options = { })
      h = super(options)
      h[:has_children] = children.size > 0
      h
    end

  end
end
