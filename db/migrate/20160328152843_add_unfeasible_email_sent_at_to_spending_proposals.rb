class AddUnfeasibleEmailSentAtToSpendingProposals < ActiveRecord::Migration
  def change
    add_column :spending_proposals, :unfeasible_email_sent_at, :datetime, default: nil
  end
end
