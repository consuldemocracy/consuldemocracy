class CreateProposalDashboardActions < ActiveRecord::Migration[4.2]
  def change
    create_table :proposal_dashboard_actions do |t|
      t.string :title, limit: 80
      t.string :description
      t.string :link
      t.boolean :request_to_administrators, default: false
      t.integer :day_offset, default: 0
      t.integer :required_supports, default: 0
      t.integer :order, default: 0
      t.boolean :active, default: true
      t.datetime :hidden_at
    end
  end
end
