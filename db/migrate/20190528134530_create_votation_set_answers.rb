class CreateVotationSetAnswers < ActiveRecord::Migration[5.0]
  def change
    create_table :votation_set_answers do |t|
      t.integer :author_id, index: true
      t.references :votation_type, foreign_key: true, index: true
      t.string :answer

      t.timestamps
    end
  end
end
