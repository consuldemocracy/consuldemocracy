module Taggable
  extend ActiveSupport::Concern

  MAX_NUMBER_OF_TAGS = 6

  included do
    acts_as_taggable
    validate :max_number_of_tags, on: :create
    before_validation :sanitize_tag_list
  end

  def tag_list_with_limit(limit = nil)
    return tags if limit.blank?

    tags.sort { |a, b| b.taggings_count <=> a.taggings_count }[0, limit]
  end

  def max_number_of_tags
    if tag_list.count > MAX_NUMBER_OF_TAGS
      errors.add(:tag_list, :less_than_or_equal_to, count: MAX_NUMBER_OF_TAGS)
    end
  end

  protected

    def sanitize_tag_list
      self.tag_list = TagSanitizer.new.sanitize_tag_list(tag_list)
    end
end
