class RemoveDeprecatedTranslatableFieldsFromPollQuestions < ActiveRecord::Migration[4.2]
  def change
    remove_column :poll_questions, :title, :string
  end
end
