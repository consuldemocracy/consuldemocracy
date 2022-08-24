module Mutations
  class SupportProposal < BaseMutation
    argument :id, ID, required: true

    type Types::ProposalType

    def resolve(id:)
      begin
        @proposal = Proposal.find(id)
        @follow = Follow.find_or_create_by!(user: context[:current_resource], followable: @proposal)
        @proposal.register_vote(context[:current_resource], "yes")
        @proposal
      rescue ActiveRecord::RecordNotFound => e
        raise GraphQL::ExecutionError, e.message
      end
    end
  end
end
