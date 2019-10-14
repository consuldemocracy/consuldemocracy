class IncreaseSpendingProposalTitleCharsLimit < ActiveRecord::Migration
  def change
    change_column :spending_proposals, :title, :string, limit: 255
  end
end
