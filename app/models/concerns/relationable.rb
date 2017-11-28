module Relationable
  extend ActiveSupport::Concern

  included do
    has_many :related_contents, as: :parent_relationable, dependent: :destroy
  end

  def report_related_content(relationable)
    related_content = related_contents.find_by(child_relationable: relationable)
    if related_content.present?
      related_content.increment!(:times_reported)
      related_content.opposite_related_content.increment!(:times_reported)
    end
  end
end
