module LinksHelper
  def render_destroy_element_link(builder, element)
    link_to_remove_association element.new_record? ? t("links.form.cancel_button") :
                                                     t("links.form.delete_button"),
                                                     builder, class: "delete remove-element"
  end
end
