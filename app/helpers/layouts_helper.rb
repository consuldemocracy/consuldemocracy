module LayoutsHelper

  def layout_menu_link_to(text, path, is_active, options)
    if is_active
      content_tag(:span, t('shared.you_are_in'), class: 'show-for-sr') + ' ' +
        link_to(text, path, options.merge(class: "is-active"))
    else
      link_to(text, path, options)
    end
  end

end
