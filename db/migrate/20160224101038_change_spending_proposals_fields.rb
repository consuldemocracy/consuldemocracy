class ChangeSpendingProposalsFields < ActiveRecord::Migration[4.2]
  def change
    remove_index :spending_proposals, column: :resolution

    remove_column :spending_proposals, :legal, :boolean
    remove_column :spending_proposals, :resolution, :string
    remove_column :spending_proposals, :explanation, :text

    add_column :spending_proposals, :price_explanation, :text
    add_column :spending_proposals, :feasible_explanation, :text
    add_column :spending_proposals, :internal_comments, :text
    add_column :spending_proposals, :valuation_finished, :boolean, default: false
    add_column :spending_proposals, :explanations_log, :text
    add_column :spending_proposals, :administrator_id, :integer
  end
end
