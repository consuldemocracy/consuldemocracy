module Types
  class DebateAttributes < Types::BaseInputObject
    argument :title, String, required: true, validates: { allow_blank: false }
    argument :description, String, required: true, validates: { allow_blank: false }
    argument :tag_list, String, required: false
  end
end
