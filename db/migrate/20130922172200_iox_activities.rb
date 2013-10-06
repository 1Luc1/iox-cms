class IoxActivities < ActiveRecord::Migration
  def change
    create_table :iox_activities do |t|

      t.references :user
      t.integer    :obj_id
      t.string     :obj_type
      t.string     :obj_name
      t.string     :obj_path
      t.string     :recipient_name # in case of moving
      t.string     :recipient_path # in case of moving
      t.string     :action, required: true
      t.string     :icon_class

      t.timestamps

    end
  end
end