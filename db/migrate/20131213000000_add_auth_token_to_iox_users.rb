class AddAuthTokenToIoxUsers < ActiveRecord::Migration
  def change
    add_column :iox_users, :auth_token, :string
    add_column :iox_users, :domain_id, :integer
  end
end
