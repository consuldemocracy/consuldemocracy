module Mutations
  class StartDebate < BaseMutation
    argument :title, String, required: true, validates: { allow_blank: false }
    argument :description, String, required: true, validates: { allow_blank: false }
    argument :tag_list, String, required: false
    argument :terms_of_service, Boolean, required: true

    type Types::DebateType

    def resolve(title:, description:, terms_of_service:, tag_list: nil)
      begin
        Debate.create!({
          translations_attributes: {
            '0': {
              locale: context[:current_resource].locale,
              title: title,
              description: description
            }
          },
          author: context[:current_resource],
          tag_list: tag_list,
          terms_of_service: terms_of_service
        })
      rescue ActiveRecord::RecordInvalid => e
        raise GraphQL::ExecutionError, "#{e.message}"
      end
    end
  end
end
