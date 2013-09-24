class IoxTranslations < ActiveRecord::Migration
  def change
    create_table :iox_translations do |t|

      t.string :locale, default: 'default'
      t.string :template, default: 'default'
      t.string :title
      t.string :subtitle
      t.string :meta_description
      t.string :meta_keywords
      t.text   :content

      t.integer :created_by
      t.integer :updated_by
      t.integer :deleted_by

      t.belongs_to :webbit
      t.belongs_to :webpage

      t.datetime :deleted_at
      t.timestamps
    end
  end
end
