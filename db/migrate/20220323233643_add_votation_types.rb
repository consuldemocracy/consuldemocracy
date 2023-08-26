class AddVotationTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :votation_types do |t|
      t.integer :questionable_id
      t.string :questionable_type
      t.integer :vote_type
      t.integer :max_votes

      t.timestamps
    end
  end
end
