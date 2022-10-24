module LayoutsHelper
  def layout_menu_link_to(text, path, is_active, options)
    title = t("shared.go_to_page") + text

    if is_active
      tag.span(t("shared.you_are_in"), class: "show-for-sr") + " " +
        link_to(text, path, options.merge(class: "is-active", title: title))
    else
      link_to(text, path, options.merge(title: title))
    end
  end
end
