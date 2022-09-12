class AddOriginParticipacionToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :origin_participacion, :boolean
  end
end
