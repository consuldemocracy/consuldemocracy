module TextWithLinksHelper

  def text_with_links(text)
    return unless text
    sanitized = sanitize(text, tags: [], attributes: [])
    Rinku.auto_link(sanitized, :all, 'target="_blank" rel="nofollow"').html_safe
  end

  def safe_html_with_links(html)
    return html unless html.html_safe?
    Rinku.auto_link(html, :all, 'target="_blank" rel="nofollow"').html_safe
  end

end
