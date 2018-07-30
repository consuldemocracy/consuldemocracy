class SiteCustomization::Image < ActiveRecord::Base
  VALID_IMAGES = {
    "icon_home" => [330, 240],
    "logo_header" => [80, 80],
    "social_media_icon" => [470, 246],
    "social_media_icon_twitter" => [246, 246],
    "apple-touch-icon-200" => [200, 200]
  }

  has_attached_file :image

  validates :name, presence: true, uniqueness: true, inclusion: { in: VALID_IMAGES.keys }
  validates_attachment_content_type :image, content_type: ["image/png"]
  validate :check_image

  def self.all_images
    VALID_IMAGES.keys.map do |image_name|
      find_by(name: image_name) || create!(name: image_name.to_s)
    end
  end

  def self.image_path_for(filename)
    image_name = filename.split(".").first

    imageable = find_by(name: image_name)
    imageable.present? && imageable.image.exists? ? imageable.image.url : nil
  end

  def required_width
    VALID_IMAGES[name].try(:first)
  end

  def required_height
    VALID_IMAGES[name].try(:second)
  end

  private

    def check_image
      return unless image?

      dimensions = Paperclip::Geometry.from_file(image.queued_for_write[:original].path)

      errors.add(:image, :image_width, required_width: required_width) unless dimensions.width == required_width
      errors.add(:image, :image_height, required_height: required_height) unless dimensions.height == required_height
    end

end
