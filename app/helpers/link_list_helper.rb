module LinkListHelper
  def link_list(*links, **options)
    return "" if links.compact.empty?

    tag.ul(options) do
      safe_join(links.compact.map do |text, url, **link_options|
        tag.li do
          link_to text, url, link_options
        end
      end)
    end
  end
end
