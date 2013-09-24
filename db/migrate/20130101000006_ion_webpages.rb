class IonWebpages < ActiveRecord::Migration
  def change
    create_table :ion_webpages do |t|

      t.string  :name
      t.string  :slug, index: true
      t.string  :template

      t.integer :master_id
      t.integer :parent_id

      t.integer :updated_by
      t.integer :created_by

      t.boolean :published, default: false

      t.integer :position, default: 99

      t.datetime :deleted_at

      t.timestamps
    end
  end
end
