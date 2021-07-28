module Attachable
  include HasAttachment
  extend ActiveSupport::Concern

  included do
    has_attachment :attachment
    attr_accessor :cached_attachment

    validate :attachment_presence

    validates :attachment,
      file_content_type: {
        allow: ->(record) { record.accepted_content_types },
        if: -> { association_class && attachment.attached? },
        message: ->(record, *) do
          I18n.t("#{record.model_name.plural}.errors.messages.wrong_content_type",
                 content_type: record.attachment_content_type,
                 accepted_content_types: record.class.humanized_accepted_content_types)
        end
      },
      file_size: {
        less_than_or_equal_to: ->(record) { record.max_file_size.megabytes },
        if: -> { association_class && attachment.attached? },
        message: ->(record, *) do
          I18n.t("#{record.model_name.plural}.errors.messages.in_between",
                 min: "0 Bytes",
                 max: "#{record.max_file_size} MB")
        end
      }

    before_validation :set_attachment_from_cached_attachment, if: -> { cached_attachment.present? }
  end

  def association_class
    type = send("#{association_name}_type")

    type.constantize if type.present?
  end

  def set_cached_attachment_from_attachment
    self.cached_attachment = attachment.signed_id
  end

  def set_attachment_from_cached_attachment
    self.attachment = cached_attachment
  end

  def attachment_file_name
    attachment.filename.to_s if attachment.attached?
  end

  def attachment_content_type
    attachment.blob.content_type if attachment.attached?
  end

  def attachment_file_size
    if attachment.attached?
      attachment.blob.byte_size
    else
      0
    end
  end

  def file_path
    ActiveStorage::Blob.service.path_for(attachment.blob.key)
  end

  private

    def attachment_presence
      unless attachment.attached?
        errors.add(:attachment, I18n.t("errors.messages.blank"))
      end
    end
end
