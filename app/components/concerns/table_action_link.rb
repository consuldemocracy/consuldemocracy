module TableActionLink
  extend ActiveSupport::Concern

  def link_to(text, url, **options)
    super(text, url, options)
  end
end
