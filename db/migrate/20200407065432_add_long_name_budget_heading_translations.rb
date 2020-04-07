class AddLongNameBudgetHeadingTranslations < ActiveRecord::Migration[5.0]
  def change
    add_column :budget_heading_translations, :long_name, :string, limit: 1000
  end
end
