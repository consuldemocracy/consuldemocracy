class CreatePollPairAnswers < ActiveRecord::Migration[5.0]
  def change
    create_table :poll_pair_answers do |t|
      t.references :question, index: true
      t.references :author, index: true
      t.references :answer_rigth
      t.references :answer_left

      t.timestamps
    end
  end
end
