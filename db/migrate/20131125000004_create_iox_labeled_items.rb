class CreateIoxLabeledItems < ActiveRecord::Migration
  def change
    create_table :iox_labeled_items do |t|

      t.belongs_to :label
      t.references :labelabel, polymorphic: true

      t.timestamps

    end
  end
end
