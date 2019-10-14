class AddExtraInfoToSpendingProposal < ActiveRecord::Migration
  def change
    add_column :spending_proposals, :extra_info, :string
  end
end
