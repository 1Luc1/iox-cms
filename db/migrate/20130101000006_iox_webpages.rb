class IoxWebpages < ActiveRecord::Migration
  def change
    create_table :iox_webpages do |t|

      t.string    :name
      t.string    :slug, index: true
      t.string    :template

      t.integer   :master_id
      t.integer   :parent_id

      t.string    :type

      # added at 11/10/2013
      t.boolean   :show_in_menu, default: true
      t.boolean   :show_in_sitemap, default: true

      t.iox_document_defaults
      t.timestamps
    end
  end
end
