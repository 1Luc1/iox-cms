class IonActivities < ActiveRecord::Migration
  def change
    create_table :ion_activities do |t|

      t.references :user, required: true
      t.integer    :obj_id, required: true
      t.string     :obj_type, required: true
      t.string     :obj_name, required: true
      t.string     :action, required: true

      t.timestamps

    end
  end
end