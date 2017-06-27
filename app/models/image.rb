class Image < ActiveRecord::Base
  TITLE_LEGHT_RANGE = 4..80
  MIN_SIZE = 475

  attr_accessor :content_type, :original_filename, :attachment_data, :attachment_urls
  belongs_to :imageable, polymorphic: true
  before_validation :set_styles
  has_attached_file :attachment, styles: { large: "x475", medium: "300x300#", thumb: "140x245#" },
                                 url:  "/system/:class/:attachment/:imageable_name_path/:style/:hash.:extension",
                                 hash_secret: Rails.application.secrets.secret_key_base
  validates_attachment :attachment, presence: true, content_type: { content_type:  %w(image/jpeg image/jpg) },
                                    size: { less_than: 1.megabytes }
  validates :title, presence: true, length: { in: TITLE_LEGHT_RANGE }
  validate :check_image_dimensions

  after_create :redimension_using_origin_styles
  accepts_nested_attributes_for :imageable

  # # overwrite default styles for Image class
  # def set_image_styles
  #   { large: "x#{MIN_SIZE}", medium: "300x300#", thumb: "140x245#" }
  # end
  def set_styles
    if imageable
      imageable.set_styles if imageable.respond_to? :set_styles
    else
      { large: "x#{MIN_SIZE}", medium: "300x300#", thumb: "140x245#" }
    end
  end

  Paperclip.interpolates :imageable_name_path do |attachment, _style|
    attachment.instance.imageable.class.to_s.downcase.split('::').map(&:pluralize).join('/')
  end

  private

    def redimension_using_origin_styles
      attachment.reprocess!
    end

    def check_image_dimensions
      return unless attachment?

      dimensions = Paperclip::Geometry.from_file(attachment.queued_for_write[:original].path)
      errors.add(:attachment, :min_image_width, required_min_width: MIN_SIZE) if dimensions.width < MIN_SIZE
      errors.add(:attachment, :min_image_height, required_min_height: MIN_SIZE) if dimensions.height < MIN_SIZE
    end
end
