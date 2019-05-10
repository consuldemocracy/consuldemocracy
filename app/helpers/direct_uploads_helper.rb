module DirectUploadsHelper

  def render_destroy_upload_link(direct_upload)
    label = direct_upload.resource_relation == "image" ? "images" : "documents"
    link_to t("#{label}.form.delete_button"),
            direct_upload_destroy_url("direct_upload[resource_type]": direct_upload.resource_type,
                                      "direct_upload[resource_id]": direct_upload.resource_id,
                                      "direct_upload[resource_relation]": direct_upload.resource_relation,
                                      "direct_upload[cached_attachment]": direct_upload.relation.cached_attachment,
                                      format: :json),
            method: :delete,
            remote: true,
            class: "delete remove-cached-attachment"
  end

end