module LinkListHelper
  def link_list(*links, **options)
    return "" if links.select(&:present?).empty?

    tag.ul(options) do
      safe_join(links.select(&:present?).map do |text, url, current = false, **link_options|
        tag.li(({ "aria-current": true } if current)) do
          if url
            link_to text, url, link_options
          else
            text
          end
        end
      end, "\n")
    end
  end
end
