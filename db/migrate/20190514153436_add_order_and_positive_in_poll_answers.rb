class AddOrderAndPositiveInPollAnswers < ActiveRecord::Migration[5.0]
  def change
    add_column :poll_answers, :positive, :boolean
    add_column :poll_answers, :order, :integer
  end
end
