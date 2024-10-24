class DropVotationTypes < ActiveRecord::Migration[5.0]
  def up
    drop_table :votation_set_answers
    drop_table :poll_pair_answers
    drop_table :votation_types
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
