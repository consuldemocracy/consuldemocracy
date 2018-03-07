class AddPublishingPricesPhaseToBudget < ActiveRecord::Migration
  def change
    add_column :budgets, :description_publishing_prices, :text
  end
end
