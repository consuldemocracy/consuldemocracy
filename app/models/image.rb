class Image < ApplicationRecord
  include Attachable

  has_attachment :attachment, styles: {
                                large: "x#{Setting["uploads.images.min_height"]}",
                                medium: "300x300#",
                                thumb: "140x245#"
                              },
                              url: "/system/:class/:attachment/:id_partition/:style/:hash.:extension",
                              hash_data: ":class/:style",
                              use_timestamp: false,
                              hash_secret: Rails.application.secrets.secret_key_base

  def self.styles
    {
      large: { resize: "x#{Setting["uploads.images.min_height"]}" },
      medium: { combine_options: { gravity: "center", resize: "300x300^", crop: "300x300+0+0" }},
      thumb: { combine_options: { gravity: "center", resize: "140x245^", crop: "140x245+0+0" }}
    }
  end

  belongs_to :user
  belongs_to :imageable, polymorphic: true, touch: true

  validates :title, presence: true
  validate :validate_title_length
  validates :user_id, presence: true
  validates :imageable_id, presence: true,         if: -> { persisted? }
  validates :imageable_type, presence: true,       if: -> { persisted? }
  validate :validate_image_dimensions, if: -> { storage_attachment.attached? && storage_attachment.new_record? }

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

  def variant(style)
    if style
      storage_attachment.variant(self.class.styles[style])
    else
      storage_attachment
    end
  end

  private

    def association_name
      :imageable
    end

    def imageable_class
      association_class
    end

    def validate_image_dimensions
      if accepted_content_types.include?(attachment_content_type)
        return true if imageable_class == Widget::Card

        storage_attachment.analyze unless storage_attachment.analyzed?

        width = storage_attachment.metadata[:width]
        height = storage_attachment.metadata[:height]
        min_width = Setting["uploads.images.min_width"].to_i
        min_height = Setting["uploads.images.min_height"].to_i
        errors.add(:attachment, :min_image_width, required_min_width: min_width) if width < min_width
        errors.add(:attachment, :min_image_height, required_min_height: min_height) if height < min_height
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
end
