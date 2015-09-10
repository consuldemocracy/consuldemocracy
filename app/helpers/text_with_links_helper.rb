module TextWithLinksHelper

  def text_with_links(text)
    return unless text
    sanitized = sanitize text, tags: [], attributes: []
    Rinku.auto_link(sanitized, :all, 'target="_blank" rel="nofollow"').html_safe
  end

end
