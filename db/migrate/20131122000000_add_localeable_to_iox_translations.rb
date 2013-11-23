class AddLocaleableToIoxTranslations < ActiveRecord::Migration
  def change
    add_column :iox_translations, :localeable_id, :integer
    add_column :iox_translations, :localeable_type, :string
  end
end
