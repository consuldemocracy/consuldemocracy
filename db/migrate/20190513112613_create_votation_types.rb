class CreateVotationTypes < ActiveRecord::Migration[5.0]
  def change
    create_table :votation_types do |t|
      t.integer :questionable_id
      t.string :questionable_type
      t.integer :enum_type
      t.boolean :open_answer
      t.boolean :prioritized
      t.integer :prioritization_type
      t.integer :max_votes
      t.integer :max_groups_answers

      t.timestamps
    end
  end
end
