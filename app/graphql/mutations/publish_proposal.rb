module Mutations
  class PublishProposal < BaseMutation
    argument :id, ID, required: true, validates: { allow_blank: false }

    type Types::ProposalType

    def resolve(id:)
      begin
        proposal = Proposal.find(id)
        proposal.publish
        proposal
      rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound => e
        raise GraphQL::ExecutionError, e.message
      end
    end
  end
end
