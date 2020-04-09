class CreateProposalExecutedDashboardActions < ActiveRecord::Migration[4.2]
  def change
    create_table :proposal_executed_dashboard_actions do |t|
      t.references :proposal, index: true, foreign_key: true
      t.references :proposal_dashboard_action, index: { name: "index_proposal_action" }, foreign_key: true
      t.datetime :executed_at
      t.text :comments

      t.timestamps null: false
    end
  end
end
