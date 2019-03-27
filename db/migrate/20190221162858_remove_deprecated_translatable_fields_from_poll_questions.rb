class RemoveDeprecatedTranslatableFieldsFromPollQuestions < ActiveRecord::Migration
  def change
    remove_column :poll_questions, :title, :string
  end
end
