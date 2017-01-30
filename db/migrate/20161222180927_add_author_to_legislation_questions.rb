class AddAuthorToLegislationQuestions < ActiveRecord::Migration
  def change
    add_column :legislation_questions, :author_id, :integer
  end
end
