class ProposalParticipant < ApplicationRecord
  belongs_to :proposal
  belongs_to :user
end
