module Types
  class DebateAttributes < GraphQL::Schema::InputObject
    class DebateTranslationAttributes < GraphQL::Schema::InputObject
      argument :title, String, required: true, validates: { allow_blank: false }
      argument :description, String, required: true, validates: { allow_blank: false }
    end
    argument :translations_attributes, [DebateTranslationAttributes], required: true

    argument :tag_list, String, required: false
    argument :terms_of_service, Boolean, required: false
  end
end
