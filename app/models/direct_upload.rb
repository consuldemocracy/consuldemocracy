class DirectUpload
  include ActiveModel::Validations

  attr_accessor :resource, :resource_type, :resource_id, :resource_relation,
                :attachment, :cached_attachment

  validates_presence_of :attachment, :resource_type, :resource_relation
  validate :parent_resource_attachment_validations,
           if: -> { attachment.present? && resource_type.present? && resource_relation.present? }

  def parent_resource_attachment_validations
    # Proposal or Budget::Investment
    resource = resource_type.constantize.find_or_initialize_by(id: resource_id)

    # Document or Image
    relation = if resource.class.reflections[resource_relation].macro == :has_one
                 resource.send("build_#{resource_relation}", attachment: attachment)
               else
                 resource.send(resource_relation).build(attachment: attachment)
               end
    relation.valid?

    if relation.errors.has_key? :attachment
      errors[:attachment] = relation.errors[:attachment]
    end
  end

end