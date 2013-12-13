class IoxDomains < ActiveRecord::Migration
  def change
    create_table :iox_domains do |t|

      t.string      :name, index: true
      t.integer     :holder_user_id

      t.timestamps

      t.boolean     :suspended
      t.boolean     :closed
      t.text        :apps

      t.attachment  :avatar

    end
  end
end
