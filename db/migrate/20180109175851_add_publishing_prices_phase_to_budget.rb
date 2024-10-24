class AddPublishingPricesPhaseToBudget < ActiveRecord::Migration[4.2]
  def change
    add_column :budgets, :description_publishing_prices, :text
  end
end
