class CratePhysicalFinalVotes < ActiveRecord::Migration[4.2]
  def change
    create_table :physical_final_votes do |t|
      t.string :signable_type
      t.string :booth
      t.integer :total_votes
      t.references :signable

      t.timestamps null: false
    end
  end
end
