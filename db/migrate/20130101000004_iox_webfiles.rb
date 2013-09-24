class IoxWebfiles < ActiveRecord::Migration
  def change
    create_table :iox_webfiles do |t|

      t.attachment  :file
      t.string      :name
      t.string      :description
      t.string      :content_type
      t.string      :copyright
      t.datetime    :orig_date
      t.boolean     :published, default: true
      t.belongs_to  :webpage

      t.timestamps

    end
  end
end