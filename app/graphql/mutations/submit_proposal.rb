module Mutations
  class SubmitProposal < BaseMutation
    argument :attributes, Types::ProposalAttributes, required: true

    type Types::ProposalType

    def resolve(attributes:)
      begin
        user = context[:current_resource]
        proposal = Proposal.new(attributes.to_hash)
        proposal.author = user
        proposal.translations.each { |translation| translation.locale = user.locale }
        proposal.image.user_id = user.id if proposal.image
        proposal.documents.each { |document| document.user_id = user.id }
        proposal.save!
        proposal
      rescue ActiveRecord::RecordInvalid => e
        raise GraphQL::ExecutionError, e.message
      end
    end
  end
end
