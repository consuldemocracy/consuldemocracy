module Sluggable
  extend ActiveSupport::Concern

  included do
    before_validation :generate_slug, if: :generate_slug?
  end

  def generate_slug
    self.slug = name.to_s.parameterize
  end
end
