class AddParticipacionIdToExternalUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :external_users, :participacion_id, :integer
  end
end
