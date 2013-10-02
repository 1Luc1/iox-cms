class IoxUsers < ActiveRecord::Migration
  def change
    create_table :iox_users do |t|

      t.string    :username, index: true
      t.string    :firstname
      t.string    :lastname

      t.string    :phone

      t.string    :time_zone
      t.string    :lang
      t.string    :email, :index => true
      t.datetime  :last_login_at
      t.datetime  :last_request_at
      t.string    :last_request_ip
      t.string    :last_login_ip
      t.text      :settings

      t.boolean   :suspended, default: false

      t.string    :roles, default: ['user']

      t.string    :password_digest

      t.string    :confirmation_key
      t.datetime  :confirmation_key_valid_until
      t.string    :registration_ip

      t.integer   :login_failures
      t.datetime  :last_login_failure
      t.string    :last_login_failure_ip

      t.datetime  :last_activities_call
      t.boolean   :registration_completed

      t.string    :can_write_apps
      t.string    :can_read_apps

      t.attachment :avatar

      t.timestamps

    end
  end
end