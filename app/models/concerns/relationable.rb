module Relationable
  extend ActiveSupport::Concern

  included do
    has_many :related_contents,
      as:         :parent_relationable,
      inverse_of: :parent_relationable,
      dependent:  :destroy
  end

  def find_related_content(relationable)
    RelatedContent.find_by(parent_relationable: self, child_relationable: relationable)
  end

  def relationed_contents
    related_contents.not_hidden.order(created_at: :asc).map(&:child_relationable)
  end
end
