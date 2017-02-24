class AddOriginToPollFinalRecounts < ActiveRecord::Migration
  def change
    add_column :poll_final_recounts, :origin, :string, default: "booth"
  end
end
