# frozen_string_literal: true

class AddActionTypeToProposalDashboardActions < ActiveRecord::Migration
  def change
    add_column :proposal_dashboard_actions, :action_type, :integer, null: false, default: 0
  end
end
