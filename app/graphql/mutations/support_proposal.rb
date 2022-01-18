module Mutations
  class SupportProposal < BaseMutation
    argument :proposal_id, ID, required: true

    type Types::ProposalType

    def resolve(proposal_id:)
      begin
        @proposal = Proposal.find(proposal_id)
        @follow = Follow.find_or_create_by!(user: context[:current_resource], followable: @proposal)
        @proposal.register_vote(context[:current_resource], "yes")
        @proposal
      rescue ActiveRecord::RecordNotFound => e
        raise GraphQL::ExecutionError, e.message
      end
    end
  end
end
