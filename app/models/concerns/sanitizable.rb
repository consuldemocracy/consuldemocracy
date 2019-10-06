module Sanitizable
  extend ActiveSupport::Concern

  included do
    before_validation :sanitize_tag_list
  end

  protected

    def sanitize_tag_list
      self.tag_list = TagSanitizer.new.sanitize_tag_list(tag_list) if self.class.taggable?
    end
end
