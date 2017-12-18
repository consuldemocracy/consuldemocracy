module Relationable
  extend ActiveSupport::Concern

  included do
    has_many :related_contents, as: :parent_relationable, dependent: :destroy
  end

  def relate_content(relationable)
    RelatedContent.find_or_create_by(parent_relationable: self, child_relationable: relationable)
  end

  def relationed_contents
    related_contents.not_hidden.map { |related_content| related_content.child_relationable }
  end

  def report_related_content(relationable)
    related_content = related_contents.find_by(child_relationable: relationable)
    if related_content.present?
      related_content.increment!(:flags_count)
      related_content.opposite_related_content.increment!(:flags_count)
    end
  end
end
