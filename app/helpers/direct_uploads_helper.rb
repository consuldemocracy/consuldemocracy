module DirectUploadsHelper
  def render_destroy_upload_link(direct_upload)
    label = direct_upload.resource_relation == "image" ? "images" : "documents"
    link_to t("#{label}.form.delete_button"), "#", class: "delete remove-cached-attachment"
  end
end
