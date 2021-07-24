class Image < ApplicationRecord
  has_attached_file :attachment, styles: {
                                   large: "x#{Setting["uploads.images.min_height"]}",
                                   medium: "300x300#",
                                   thumb: "140x245#"
                                 },
                                 url: "/system/:class/:prefix/:style/:hash.:extension",
                                 hash_data: ":class/:style",
                                 use_timestamp: false,
                                 hash_secret: Rails.application.secrets.secret_key_base
  attr_accessor :cached_attachment

  belongs_to :user
  belongs_to :imageable, polymorphic: true

  # Disable paperclip security validation due to polymorphic configuration
  # Paperclip do not allow to use Procs on valiations definition
  do_not_validate_attachment_file_type :attachment
  validate :attachment_presence
  validate :validate_attachment_content_type,         if: -> { attachment.present? }
  validate :validate_attachment_size,                 if: -> { attachment.present? }
  validates :title, presence: true
  validate :validate_title_length
  validates :user_id, presence: true
  validates :imageable_id, presence: true,         if: -> { persisted? }
  validates :imageable_type, presence: true,       if: -> { persisted? }
  validate :validate_image_dimensions, if: -> { attachment.present? && attachment.dirty? }

  before_save :set_attachment_from_cached_attachment, if: -> { cached_attachment.present? }

  def self.max_file_size
    Setting["uploads.images.max_size"].to_i
  end

  def self.accepted_content_types
    Setting["uploads.images.content_types"]&.split(" ") || ["image/jpeg"]
  end

  def self.humanized_accepted_content_types
    Setting.accepted_content_types_for("images").join(", ")
  end

  def max_file_size
    self.class.max_file_size
  end

  def accepted_content_types
    self.class.accepted_content_types
  end

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
    if attachment.instance.persisted?
      ":attachment/:id_partition"
    else
      "cached_attachments/user/#{attachment.instance.user_id}"
    end
  end

  private

    def imageable_class
      imageable_type.constantize if imageable_type.present?
    end

    def validate_image_dimensions
      if attachment_of_valid_content_type?
        return true if imageable_class == Widget::Card

        dimensions = Paperclip::Geometry.from_file(attachment.queued_for_write[:original].path)
        min_width = Setting["uploads.images.min_width"].to_i
        min_height = Setting["uploads.images.min_height"].to_i
        errors.add(:attachment, :min_image_width, required_min_width: min_width) if dimensions.width < min_width
        errors.add(:attachment, :min_image_height, required_min_height: min_height) if dimensions.height < min_height
      end
    end

    def validate_attachment_size
      if imageable_class && attachment_file_size > max_file_size.megabytes
        errors.add(:attachment, I18n.t("images.errors.messages.in_between",
                                     min: "0 Bytes",
                                     max: "#{max_file_size} MB"))
      end
    end

    def validate_title_length
      if title.present?
        title_min_length = Setting["uploads.images.title.min_length"].to_i
        title_max_length = Setting["uploads.images.title.max_length"].to_i

        if title.size < title_min_length
          errors.add(:title, I18n.t("errors.messages.too_short", count: title_min_length))
        end

        if title.size > title_max_length
          errors.add(:title, I18n.t("errors.messages.too_long", count: title_max_length))
        end
      end
    end

    def validate_attachment_content_type
      if imageable_class && !attachment_of_valid_content_type?
        message = I18n.t("images.errors.messages.wrong_content_type",
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

    def attachment_of_valid_content_type?
      attachment.present? && accepted_content_types.include?(attachment_content_type)
    end
end
