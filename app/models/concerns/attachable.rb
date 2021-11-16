module Attachable
  include HasAttachment
  extend ActiveSupport::Concern

  included do
    attr_accessor :cached_attachment

    # Disable paperclip security validation due to polymorphic configuration
    # Paperclip do not allow to use Procs on valiations definition
    do_not_validate_attachment_file_type :attachment
    validate :attachment_presence
    validate :validate_attachment_content_type,         if: -> { attachment.present? }
    validate :validate_attachment_size,                 if: -> { attachment.present? }

    before_save :set_attachment_from_cached_attachment, if: -> { cached_attachment.present? }

    Paperclip.interpolates :prefix do |attachment, style|
      attachment.instance.prefix(attachment, style)
    end
  end

  def association_class
    type = send("#{association_name}_type")

    type.constantize if type.present?
  end

  def set_cached_attachment_from_attachment
    self.cached_attachment = if filesystem_storage?
                               attachment.path
                             else
                               attachment.url
                             end
  end

  def set_attachment_from_cached_attachment
    if filesystem_storage?
      File.open(cached_attachment) { |file| self.attachment = file }
    else
      self.attachment = URI.parse(cached_attachment).open
    end
  end

  def prefix(attachment, _style)
    if attachment.instance.persisted?
      ":attachment/:id_partition"
    else
      "cached_attachments/user/#{attachment.instance.user_id}"
    end
  end

  private

    def filesystem_storage?
      Paperclip::Attachment.default_options[:storage] == :filesystem
    end

    def validate_attachment_size
      if association_class && attachment_file_size > max_file_size.megabytes
        errors.add(:attachment, I18n.t("#{model_name.plural}.errors.messages.in_between",
                                       min: "0 Bytes",
                                       max: "#{max_file_size} MB"))
      end
    end

    def validate_attachment_content_type
      if association_class && !accepted_content_types.include?(attachment_content_type)
        message = I18n.t("#{model_name.plural}.errors.messages.wrong_content_type",
                         content_type: attachment_content_type,
                         accepted_content_types: self.class.humanized_accepted_content_types)
        errors.add(:attachment, message)
      end
    end

    def attachment_presence
      if attachment.blank? && cached_attachment.blank?
        errors.add(:attachment, I18n.t("errors.messages.blank"))
      end
    end
end
