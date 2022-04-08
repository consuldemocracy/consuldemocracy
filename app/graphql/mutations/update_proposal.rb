module Mutations
  class UpdateProposal < BaseMutation
    argument :id, ID, required: true
    argument :attributes, Types::ProposalAttributes, required: true

    type Types::ProposalType

    def resolve(id:, attributes:)
      begin
        user = context[:current_resource]
        proposal = Proposal.find(id)

        unless proposal.author == user
          raise GraphQL::ExecutionError, "User '#{user.username}' is not authorized to update Debate with id '#{debate.id}'"
        end

        attributes_hash = attributes.to_hash
        attributes_hash[:translations_attributes].each { |translation| translation[:locale] = user.locale }
        attributes_hash[:image_attributes][:user_id] = user.id if attributes_hash.key? :image_attributes
        attributes_hash[:documents_attributes].each { |document| document[:user_id] = user.id }

        # TODO: This right here is a hotfix.
        # What we really want to do is get the right IDs and pass them
        # so that the actual models are updated
        #
        # This would require to have a QueryType where the Translations
        # are returned, which is not yet implemented. We could think
        # about that, when we decide that we need to update Proposals
        proposal.translations.where(locale: user.locale).delete_all
        proposal.update_attributes!(attributes_hash)
        proposal
      rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound => e
        raise GraphQL::ExecutionError, e.message
      end
    end
  end
end
