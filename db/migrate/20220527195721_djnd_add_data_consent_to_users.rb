class DjndAddDataConsentToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :data_consent, :boolean, default: false
  end
end
