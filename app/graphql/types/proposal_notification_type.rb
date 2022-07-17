module Types
  class ProposalNotificationType < Types::BaseObject
    field :body, String, null: true
    field :id, ID, null: false
    field :proposal, Types::ProposalType, null: true
    field :proposal_id, Integer, null: true
    field :public_created_at, String, null: true
    field :title, String, null: true

    def proposal
      Proposal.public_for_api.find_by(id: object.proposal)
    end
  end
end
