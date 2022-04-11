class AddQuestionsToBudgetsTranslations < ActiveRecord::Migration[5.2]
  def change
    add_column :budget_translations, :questions, :text, array: true, default: []
  end
end
