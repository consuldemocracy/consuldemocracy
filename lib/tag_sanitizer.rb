class TagSanitizer
  TAG_MAX_LENGTH = 40

  DISALLOWED_STRINGS = %w(? < > = /)

  def sanitize_tag(tag)
    tag = tag.dup
    DISALLOWED_STRINGS.each do |s|
      tag.gsub!(s, '')
    end
    tag.truncate(TAG_MAX_LENGTH)
  end

  def sanitize_tag_list(tag_list)
    tag_list.map { |tag| sanitize_tag(tag) }
  end

end
