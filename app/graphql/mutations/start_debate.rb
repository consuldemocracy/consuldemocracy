module Mutations
  class StartDebate < BaseMutation

    argument :attributes, Types::DebateAttributes, required: true

    type Types::DebateType

    def resolve(attributes:)
      begin
        user = context[:current_resource]
        debate = Debate.new(attributes.to_hash)
        debate.author = user
        debate.translations.each { |translation| translation.locale = user.locale }
        debate.save!
        debate
      rescue ActiveRecord::RecordInvalid => e
        raise GraphQL::ExecutionError, e.message
      end
    end
  end
end
