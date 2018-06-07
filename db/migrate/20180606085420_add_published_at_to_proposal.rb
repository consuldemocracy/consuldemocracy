class AddPublishedAtToProposal < ActiveRecord::Migration
  def change
    add_column :proposals, :published_at, :datetime, null: true

    Proposal.draft.find_each do |proposal|
      proposal.update(published_at: proposal.created_at)
    end
  end
end
