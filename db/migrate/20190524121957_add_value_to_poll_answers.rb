class AddValueToPollAnswers < ActiveRecord::Migration[5.0]
  def change
    add_column :poll_answers, :value, :integer
  end
end
