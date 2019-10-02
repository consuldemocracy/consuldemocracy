module TextWithLinksHelper

  def sanitize_and_auto_link(text)
    return unless text
    sanitized = sanitize(text, tags: [], attributes: [])
    Rinku.auto_link(sanitized, :all, 'target="_blank" rel="nofollow"').html_safe
  end

  def auto_link_already_sanitized_html(html)
    return if html.nil?
    raise "Could not add links because the content is not safe" unless html.html_safe?

    Rinku.auto_link(html, :all, 'target="_blank" rel="nofollow"').html_safe
  end

  def simple_format_no_tags_no_sanitize(html)
    simple_format(html, {}, sanitize: false)
  end

end
