class TagSanitizer

  DISALLOWED_STRINGS = %w(? < > = /)

  def sanitize_tag(tag)
    tag = tag.dup
    DISALLOWED_STRINGS.each do |s|
      tag.gsub!(s, '')
    end
    tag
  end

  def sanitize_tag_list(tag_list)
    tag_list.map { |tag| sanitize_tag(tag) }
  end

end
