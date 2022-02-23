class SiteCustomization::Image < ApplicationRecord
  include HasAttachment

  VALID_IMAGES = {
    "logo_header" => [260, 80],
    "social_media_icon" => [470, 246],
    "social_media_icon_twitter" => [246, 246],
    "apple-touch-icon-200" => [200, 200],
    "budget_execution_no_image" => [800, 600],
    "budget_investment_no_image" => [800, 600],
    "budget_no_image" => [400, 300],
    "map" => [420, 500],
    "logo_email" => [400, 80],
    "welcome/step_1" => [270, 240],
    "welcome/step_2" => [270, 240],
    "welcome/step_3" => [270, 240],
    "welcome_process" => [370, 185],
    "auth_bg" => [934, 1398],
    "bg_footer" => [1200, 300],
    "logo_footer" => [260, 80]
  }.freeze

  has_attachment :image

  validates :name, presence: true, uniqueness: true, inclusion: { in: VALID_IMAGES.keys }
  validates_attachment_content_type :image, content_type: ["image/png", "image/jpeg"]
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
    VALID_IMAGES[name]&.first
  end

  def required_height
    VALID_IMAGES[name]&.second
  end

  private

    def check_image
      return unless image?

      dimensions = Paperclip::Geometry.from_file(image.queued_for_write[:original].path)

      unless dimensions.width >= required_width
        errors.add(:image, :image_width, required_width: required_width)
      end

      unless dimensions.height >= required_height
        errors.add(:image, :image_height, required_height: required_height)
      end
    end
end
