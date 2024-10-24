class AddAuthorToLegislationQuestions < ActiveRecord::Migration[4.2]
  def change
    add_column :legislation_questions, :author_id, :integer
  end
end
