class AddCommentsCountToLegislationQuestions < ActiveRecord::Migration
  def change
    add_column :legislation_questions, :comments_count, :integer, default: 0
  end
end
