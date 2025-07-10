module Sluggable
  extend ActiveSupport::Concern

  included do
    before_validation :generate_slug, if: :generate_slug?

    def self.find_by_slug_or_id(slug_or_id)
      find_by(slug: slug_or_id) || find_by(id: slug_or_id)
    end

    def self.find_by_slug_or_id!(slug_or_id)
      find_by(slug: slug_or_id) || find(slug_or_id)
    end
  end

  def generate_slug
    self.slug = name.to_s.parameterize
  end
end
