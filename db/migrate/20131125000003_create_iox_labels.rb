class CreateIoxLabels < ActiveRecord::Migration
  def change
    create_table :iox_labels do |t|

      t.string      :name
      t.integer     :parent_id
      t.string      :type

      t.references  :labelabel, polymorphic: true

      t.iox_document_defaults

      t.timestamps

    end
  end
end
