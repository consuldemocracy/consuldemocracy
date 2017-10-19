module Sluggable
  extend ActiveSupport::Concern

  included do
    before_validation :generate_slug, if: :update_slug?
  end

  def generate_slug
    self.slug = name.to_s.parameterize
  end

  def update_slug?
    new_record? || (name_changed? && (name_was.to_s.parameterize == slug))
  end
end
