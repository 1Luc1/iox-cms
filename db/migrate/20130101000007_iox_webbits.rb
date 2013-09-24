class IoxWebbits < ActiveRecord::Migration
  def change
    create_table :iox_webbits do |t|

      t.string  :name
      t.string	:plugin_type
      t.string  :css_classes

      t.belongs_to :webpage

    end
  end
end
