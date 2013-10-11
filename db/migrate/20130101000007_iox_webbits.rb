class IoxWebbits < ActiveRecord::Migration
  def change
    create_table :iox_webbits do |t|

      t.string  :name
      t.string	:plugin_type
      t.string  :css_classes

      t.belongs_to :webpage

      # new as of 08/10/2013
      t.string  :category
      t.string  :icon, default: 'icon-align-left'
      t.datetime :deleted_at
      t.integer :parent_id
      t.integer :links_to_webbit_id       # if this webbit links to another webbit,
                                          # which should be used instead

      t.timestamps

    end
  end
end
