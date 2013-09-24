class IoxWebpageStats < ActiveRecord::Migration
  def change
    create_table :iox_webpage_stats do |t|

      t.string :ip_addr
      t.string :user_agent
      t.string :os

      t.integer :views, default: 1
      t.integer :visits, default: 1

      t.string :lang

      t.belongs_to :webpage

      t.date :day, index: true

      t.timestamps
    end
  end
end
