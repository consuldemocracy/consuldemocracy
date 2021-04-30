class ProposalOnProject < ApplicationRecord
  belongs_to :project
  belongs_to :proposal
end
