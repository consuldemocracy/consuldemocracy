class Document < ActiveRecord::Base
  include DocumentsHelper
  include DocumentablesHelper
  has_attached_file :attachment, url: "/system/:class/:prefix/:style/:hash.:extension",
                                 hash_data: ":class/:style",
                                 use_timestamp: false,
                                 hash_secret: Rails.application.secrets.secret_key_base
  attr_accessor :cached_attachment

  belongs_to :user
  belongs_to :documentable, polymorphic: true

  # Disable paperclip security validation due to polymorphic configuration
  # Paperclip do not allow to use Procs on valiations definition
  do_not_validate_attachment_file_type :attachment
  validate :attachment_presence
  validate :validate_attachment_content_type,         if: -> { attachment.present? }
  validate :validate_attachment_size,                 if: -> { attachment.present? }
  validates :title, presence: true
  validates :user_id, presence: true
  validates :documentable_id, presence: true,         if: -> { persisted? }
  validates :documentable_type, presence: true,       if: -> { persisted? }

  before_save :set_attachment_from_cached_attachment, if: -> { cached_attachment.present? }
  after_save :remove_cached_attachment,               if: -> { cached_attachment.present? }

  def set_cached_attachment_from_attachment
    self.cached_attachment = if Paperclip::Attachment.default_options[:storage] == :filesystem
                               attachment.path
                             else
                               attachment.url
                             end
  end

  def set_attachment_from_cached_attachment
    self.attachment = if Paperclip::Attachment.default_options[:storage] == :filesystem
                        File.open(cached_attachment)
                      else
                        URI.parse(cached_attachment)
                      end
  end

  Paperclip.interpolates :prefix do |attachment, style|
    attachment.instance.prefix(attachment, style)
  end

  def prefix(attachment, _style)
    if !attachment.instance.persisted?
      "cached_attachments/user/#{attachment.instance.user_id}"
    else
      ":attachment/:id_partition"
    end
  end

  def humanized_content_type
    attachment_content_type.split("/").last.upcase
  end

  private

    def documentable_class
      documentable_type.constantize if documentable_type.present?
    end

    def validate_attachment_size
      if documentable_class.present? &&
         attachment_file_size > documentable_class.max_file_size
        errors[:attachment] = I18n.t("documents.errors.messages.in_between",
                                      min: "0 Bytes",
                                      max: "#{max_file_size(documentable_class)} MB")
      end
    end

    def validate_attachment_content_type
      if documentable_class &&
         !accepted_content_types(documentable_class).include?(attachment_content_type)
        errors[:attachment] = I18n.t("documents.errors.messages.wrong_content_type",
                                      content_type: attachment_content_type,
                                      accepted_content_types: documentable_humanized_accepted_content_types(documentable_class))
      end
    end

    def attachment_presence
      if attachment.blank? && cached_attachment.blank?
        errors[:attachment] = I18n.t("errors.messages.blank")
      end
    end

    def remove_cached_attachment
      document = Document.new(documentable: documentable,
                              cached_attachment: cached_attachment,
                              user: user)
      document.set_attachment_from_cached_attachment
      document.attachment.destroy
    end

end
