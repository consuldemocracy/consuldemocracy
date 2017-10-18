class DirectUpload
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :resource, :resource_type, :resource_id,
                :relation, :resource_relation,
                :attachment, :cached_attachment, :user

  validates :attachment, :resource_type, :resource_relation, :user, presence: true
  validate :parent_resource_attachment_validations,
           if: -> { attachment.present? && resource_type.present? && resource_relation.present? && user.present? }

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end

    if @resource_type.present? && @resource_relation.present? && (@attachment.present? || @cached_attachment.present?)
      @resource = @resource_type.constantize.find_or_initialize_by(id: @resource_id)

      # Refactor
      @relation = if @resource.respond_to?(:images) &&
                     ((@attachment.present? && !@attachment.content_type.match(/pdf/)) || @cached_attachment.present?)
        @resource.images.send("build", relation_attributtes)
                  elsif @resource.class.reflections[@resource_relation].macro == :has_one
        @resource.send("build_#{resource_relation}", relation_attributtes)
                  else
        @resource.send(@resource_relation).build(relation_attributtes)
                  end

      @relation.user = user
    end
  end

  def save_attachment
    @relation.attachment.save
  end

  def destroy_attachment
    @relation.attachment.destroy
  end

  def persisted?
    false
  end

  private

  def parent_resource_attachment_validations
    @relation.valid?

    if @relation.errors.key? :attachment
      errors[:attachment] = @relation.errors[:attachment]
    end
  end

  def relation_attributtes
    {
      attachment: @attachment,
      cached_attachment: @cached_attachment,
      user: @user
    }
  end

end