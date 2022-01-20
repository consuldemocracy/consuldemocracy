module Mutations
  class StartDebate < BaseMutation

    argument :attributes, Types::DebateAttributes, required: true
    argument :terms_of_service, Boolean, required: true

    type Types::DebateType

    def resolve(attributes:, terms_of_service:)
      begin
        Debate.create!({
          translations_attributes: {
            '0': {
              locale: context[:current_resource].locale,
              title: arguments[:title],
              description: arguments[:description]
            }
          },
          author: context[:current_resource],
          tag_list: arguments[:tag_list],
          terms_of_service: terms_of_service
        })
      rescue ActiveRecord::RecordInvalid => e
        raise GraphQL::ExecutionError, e.message
      end
    end
  end
end
