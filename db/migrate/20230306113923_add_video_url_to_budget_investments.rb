class AddVideoUrlToBudgetInvestments < ActiveRecord::Migration[6.0]
  def change
     add_column :budget_investments, :video_url, :string
  end
end
