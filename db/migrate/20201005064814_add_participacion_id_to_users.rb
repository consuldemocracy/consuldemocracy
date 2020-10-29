class AddParticipacionIdToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :participacion_id, :integer
  end
end
