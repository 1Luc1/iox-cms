module Iox

  class UniqueTemplateValidator < ActiveModel::Validator
    def validate(record)
      tmpl_filename = File.join( Rails.root, 'config', 'iox_webpage_fixtures', "#{record.template}_data.yml" )
      if File.exists? tmpl_filename
        tmpl_data = HashWithIndifferentAccess.new(YAML::load_file( tmpl_filename ))
        puts "not found #{tmpl_data}"
        if( tmpl_data[:unique] ) && Iox::Webpage.where("template='#{record.template}'#{" AND id != #{record.id}" unless record.new_record?}" ).count > 0
          record.errors[:template] << 'A webpage with that template already exists. Only one is allowed!'
        end
      end
    end
  end

  class Webpage < ActiveRecord::Base

    acts_as_iox_document

    attr_accessor :translation, :locale

    default_scope { where( deleted_at: nil ) }

    has_many :webbits, -> { order(:position) }, class_name: 'Iox::Webbit', dependent: :delete_all
    has_many :translations, dependent: :delete_all

    has_many :children, -> { where("deleted_at IS NULL").order(:position) }, class_name: 'Iox::Webpage', foreign_key: 'parent_id', dependent: :destroy
    has_many :stats, class_name: 'Iox::WebpageStat', dependent: :delete_all

    belongs_to :parent, class_name: 'Iox::Webpage', foreign_key: 'parent_id', inverse_of: :children
    belongs_to :master, class_name: 'Iox::Webpage', foreign_key: 'master_id', inverse_of: :widgets

    belongs_to :creator, class_name: 'Iox::User', foreign_key: :created_by
    belongs_to :updater, class_name: 'Iox::User', foreign_key: :updated_by

    accepts_nested_attributes_for :translations
    accepts_nested_attributes_for :webbits

    has_many :text_webbits, -> { where( plugin_type: 'text') }, class_name: 'Iox::Webbit'

    has_many :webfiles, dependent: :destroy
    has_many :images, -> { where("content_type LIKE 'image%'") }, class_name: 'Iox::Webfile'

    # calculate amount of views of this webpage in the last 7 days
    #
    #
    def views
      #stats.where("created_at > ?", 7.days.ago).count
      stats.count
    end

    validates_with UniqueTemplateValidator
    validates :name, presence: true

    before_create      :create_slug
    before_create      :publish_if_frontpage
    after_create       :init_webbits


    def tmpl_filename
      File.join( Rails.root, 'config', 'iox_webpage_fixtures', "#{template}_data.yml" )
    end

    def as_json(options = { })
      h = super(options)
      h[:num_children] = children.count
      h[:translation] = translation
      h
    end

    def siblings( count_only=nil )
      conditions = {parent_id: nil}
      conditions = {parent_id: parent_id} unless parent_id.blank?
      siblings = self.class.where("deleted_at IS NULL").where( conditions ).order(:position)
      return siblings.count if count_only == :count_only
      siblings.load
    end

    def pos_within_siblings
      pos = nil
      siblings.each_with_index do |sibling,i|
        pos = i if sibling.id == id
      end
      pos
    end

    def next_sibling
      conditions = {parent_id: nil}
      conditions = {parent_id: parent_id} unless parent_id.blank?
      cnt = siblings( :count_only )
      puts "#{name} HAVING COUNT #{cnt} and position #{pos_within_siblings}"
      if pos_within_siblings <= cnt
        return siblings[pos_within_siblings+1]
      end
    end

    def next_sibling_id
      next_sibling ? next_sibling.slug : nil
    end

    def next_sibling_slug
      next_sibling ? next_sibling.slug : nil
    end

    def prev_sibling
      conditions = {parent_id: nil}
      conditions = {parent_id: parent_id} unless parent_id.blank?
      if pos_within_siblings > 0
        return siblings[pos_within_siblings-1]
      end
    end

    def prev_sibling_id
      prev_sibling ? prev_sibling.slug : nil
    end

    def prev_sibling_slug
      prev_sibling ? prev_sibling.slug : nil
    end

    def translation
      return @translation if @translation
      @translation = translations.where( locale: locale ).first
      @translation = translations.create!( locale: locale ) if !@translation && !new_record?
      @translation
    end

    def to_param
      [id, name.parameterize].join("-")
    end

    private

    def publish_if_frontpage
      published = true if template === 'frontpage'
    end

    def init_webbits
      if File.exists? tmpl_filename
        tmpl_data = YAML::load_file( tmpl_filename )
        tmpl_data.each_pair do |name, data|
          next unless data.is_a?(Hash)
          wb = self.webbits.create!( plugin_type: data['type'], 
                                    name: name, 
                                    category: data['category'],
                                    css_classes: data['css_classes'] )
          t = wb.translations.create!( locale: self.locale || I18n.default_locale, content: data['content'] )
        end
      else
        raise StandardError.new "Could not find template #{tmpl_filename}"
      end
    end

  end
end
