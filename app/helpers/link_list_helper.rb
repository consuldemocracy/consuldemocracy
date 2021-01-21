module LinkListHelper
  def link_list(*links, **options)
    return "" if links.compact.empty?

    tag.ul(options) do
      safe_join(links.compact.map do |text, url, current = false, **link_options|
        tag.li(({ "aria-current": true } if current)) do
          link_to text, url, link_options
        end
      end, "\n")
    end
  end
end
