class AddFeasibleExplanationToProposals < ActiveRecord::Migration
  def change
    add_column :proposals, :feasible_explanation, :text
  end
end
