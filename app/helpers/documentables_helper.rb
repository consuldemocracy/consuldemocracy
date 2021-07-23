module DocumentablesHelper
  def accepted_content_types(documentable_class)
    documentable_class.accepted_content_types
  end

  def documentable_humanized_accepted_content_types(documentable_class)
    Setting.accepted_content_types_for("documents").join(", ")
  end
end
