class Document < ActiveRecord::Base
  has_attached_file :attachment

  belongs_to :user
  belongs_to :documentable, polymorphic: true

  validates_attachment :attachment, presence: true
  do_not_validate_attachment_file_type :attachment
  validate :validate_attachment_content_type

  validate :validate_attachment_size
  validates :title, presence: true
  validates :user, presence: true
  validates :documentable_id, presence: true
  validates :documentable_type, presence: true

  def validate_attachment_size
    if attachment.file? && documentable.present? && attachment_file_size > documentable.class.max_file_size
      errors[:attachment] = I18n.t("documents.errors.messages.in_between",
                                    min: "0 Bytes",
                                    max: "#{bytesToMeg(documentable.class.max_file_size)} MB")
    end
  end

  def validate_attachment_content_type
    if attachment.file? && documentable.present? && !documentable.class.accepted_content_types.include?(attachment_content_type)
      errors[:attachment] = I18n.t("documents.errors.messages.content_type",
                                    content_type: attachment_content_type,
                                    accepted_content_types: documentable.class.accepted_content_types.join(", "))
    end
  end

  private

    def bytesToMeg bytes
      bytes / (1024.0 * 1024.0)
    end

end
