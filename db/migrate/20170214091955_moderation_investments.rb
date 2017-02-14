class ModerationInvestments < ActiveRecord::Migration
  def change
    add_column :budget_investments, :accepted_at, :datetime
    add_column :budget_investments, :moderation_text, :text
  end
end
