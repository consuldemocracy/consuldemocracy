module Mutations
  class UpdateDebate < BaseMutation

    argument :id, ID, required: true
    argument :attributes, Types::DebateAttributes, required: true

    type Types::DebateType

    def resolve(id:, attributes:)
      begin
        user = context[:current_resource]
        debate = Debate.find(id)

        raise_error_unless_permitted! :update, debate

        attributes_hash = attributes.to_hash
        attributes_hash[:translations_attributes].each { |translation| translation[:locale] = user.locale }

        # For some reason old translations aren't deleted
        debate.translations.where(locale: user.locale).delete_all

        debate.update_attributes!(attributes_hash)
        debate
      rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound => e
        raise GraphQL::ExecutionError, e.message
      end
    end
  end
end
