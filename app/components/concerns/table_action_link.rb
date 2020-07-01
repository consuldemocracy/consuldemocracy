module TableActionLink
  extend ActiveSupport::Concern

  def link_to(text, url, **options)
    super(tag.span(text), url, options)
  end
end
