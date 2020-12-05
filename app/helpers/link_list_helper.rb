module LinkListHelper
  def link_list(*links, **options)
    return if links.compact.empty?

    tag.ul(options) do
      safe_join(links.compact.map do |text, url = nil, current = false, **link_options|
        if url
          tag.li(({ "aria-current": true } if current)) do
            link_to text, url, link_options
          end
        else
          tag.li text
        end
      end)
    end
  end
end
