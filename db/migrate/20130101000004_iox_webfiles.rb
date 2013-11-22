class IoxWebfiles < ActiveRecord::Migration
  def change
    create_table :iox_webfiles do |t|

      t.attachment  :file
      t.string      :name
      t.string      :description
      t.string      :content_type
      t.string      :copyright
      t.datetime    :orig_date
      
      t.belongs_to  :webpage

      t.iox_document_defaults

      t.timestamps

    end
  end
end