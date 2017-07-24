class Document < ActiveRecord::Base
  include DocumentsHelper
  include DocumentablesHelper
  has_attached_file :attachment

  belongs_to :user
  belongs_to :documentable, polymorphic: true

  validates_attachment :attachment, presence: true
  # Disable paperclip security validation due to polymorphic configuration
  # Paperclip do not allow to user Procs on valiations definition
  do_not_validate_attachment_file_type :attachment
  validate :validate_attachment_content_type,         if: -> { attachment.present? }
  validate :validate_attachment_size,                 if: -> { attachment.present? }
  validates :title, presence: true
  validates :user, presence: true
  validates :documentable_id, presence: true
  validates :documentable_type, presence: true

  def validate_attachment_size
    if documentable.present? &&
       attachment_file_size > documentable.class.max_file_size
      errors[:attachment] = I18n.t("documents.errors.messages.in_between",
                                    min: "0 Bytes",
                                    max: "#{max_file_size(documentable)} MB")
    end
  end

  def validate_attachment_content_type
    if documentable.present? &&
       !accepted_content_types(documentable).include?(attachment_content_type)
      errors[:attachment] = I18n.t("documents.errors.messages.wrong_content_type",
                                    content_type: attachment_content_type,
                                    accepted_content_types: humanized_accepted_content_types(documentable))
    end
  end

end
