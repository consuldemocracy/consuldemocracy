module LinkListHelper
  def link_list(*links, **options)
    return if links.compact.empty?

    tag.ul(options) do
      safe_join(links.compact.map do |text, url, is_active = false, **link_options|
        tag.li(class: ("is-active" if is_active)) do
          link_to text, url, link_options
        end
      end)
    end
  end
end
