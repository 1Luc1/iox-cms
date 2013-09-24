module Iox
  class Webbit < ActiveRecord::Base

    attr_accessor :lang, :webbit_translation, :global

    has_many :translations, dependent: :delete_all
    accepts_nested_attributes_for :translations

  end
end
