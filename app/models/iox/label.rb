# encoding: utf-8

module Iox
  class Label < ActiveRecord::Base

    acts_as_iox_document

    has_many    :labeled_items, dependent: :destroy
    has_many    :labelabels, through: :labeled_items

    validates_uniqueness_of :name

    def as_json(options = { })
      h = super(options)
      h
    end

  end
end