class TinymceAsset < ActiveRecord::Base

  include ImageablesHelper

  attr_accessor 'file_file_name'

  MIN_SIZE = Image::MIN_SIZE
  MAX_IMAGE_SIZE = Image::MAX_IMAGE_SIZE

  has_attached_file :file, styles: { large: "x#{MIN_SIZE}", medium: "300x300#", thumb: "140x245#" },
                           url: "/system/tinymce/:style/:hash.:extension",
                           hash_data: "tinymce/:style",
                           use_timestamp: false,
                           hash_secret: Rails.application.secrets.secret_key_base

  validates_attachment_content_type :file, content_type: Image::ACCEPTED_CONTENT_TYPE

  validates :file, presence: { message: I18n.t("errors.messages.blank") }
  validate :validate_file_size
  validate :validate_image_dimensions, if: -> { file.present? && file.dirty? }

  Paperclip.interpolates :prefix do |file, style|
    file.instance.prefix(file, style)
  end

  private

    def validate_image_dimensions
      dimensions = Paperclip::Geometry.from_file(file.queued_for_write[:original].path)
      errors.add(:file, :min_image_width, required_min_width: MIN_SIZE) if dimensions.width < MIN_SIZE
      errors.add(:file, :min_image_height, required_min_height: MIN_SIZE) if dimensions.height < MIN_SIZE
    end

    def validate_file_size
      if file_file_size > MAX_IMAGE_SIZE
        errors[:file] = I18n.t("images.errors.messages.in_between",
                                min: "0 Bytes",
                                max: "#{imageable_max_file_size} MB")
      end
    end

end
