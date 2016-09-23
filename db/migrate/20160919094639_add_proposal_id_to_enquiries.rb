class AddProposalIdToEnquiries < ActiveRecord::Migration
  def change
    add_reference :enquiries, :proposal, index: true, foreign_key: true
  end
end
