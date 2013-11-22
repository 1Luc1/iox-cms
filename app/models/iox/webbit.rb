module Iox
  class Webbit < ActiveRecord::Base

    acts_as_iox_document

    attr_accessor :locale, 
      :webbit_translation, 
      :global, 
      :title, # the translation title cache
      :template, # same
      :content

    has_many :translations, dependent: :delete_all
    has_many :children, class_name: 'Iox::Webbit', dependent: :destroy, foreign_key: :parent_id, dependent: :destroy
    belongs_to :webpage
    belongs_to :parent, class_name: 'Iox::Webbit', foreign_key: 'parent_id', inverse_of: :children

    accepts_nested_attributes_for :translations

    def translation
      return @translation if @translation
      self.locale ||= webpage && webpage.locale || I18n.locale
      @translation = translations.where( locale: locale ).first
      @translation = translations.create!( locale: locale, content: '<p>REPLACE ME</p>' ) if !@translation && !new_record?
      @translation
    end

    def content
      translation ? translation.content : ''
    end

    def as_json(options = { })
      h = super(options)
      h[:has_children] = children.size > 0
      h[:title] = translation.title || name
      h[:template] = translation.template || ''
      h
    end

  end
end
