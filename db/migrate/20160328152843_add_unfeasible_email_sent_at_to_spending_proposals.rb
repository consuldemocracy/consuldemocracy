class AddUnfeasibleEmailSentAtToSpendingProposals < ActiveRecord::Migration[4.2]
  def change
    add_column :spending_proposals, :unfeasible_email_sent_at, :datetime, default: nil
  end
end
