require_dependency Rails.root.join("app", "models", "site_customization", "image").to_s

class SiteCustomization::Image
  VALID_IMAGES = {
    "logo_header" => [260, 80],
    "social_media_icon" => [470, 246],
    "social_media_icon_twitter" => [246, 246],
    "apple-touch-icon-200" => [200, 200],
    "auth_bg" => [934, 1398],
    "budget_execution_no_image" => [800, 600],
    "budget_investment_no_image" => [800, 600],
    "favicon" => [16, 16],
    "map" => [420, 500],
    "logo_email" => [400, 80],
    "welcome_process" => [370, 185],
    "budget_no_image" => [400, 300],
    "welcome/step_1" => [270, 240],
    "welcome/step_2" => [270, 240],
    "welcome/step_3" => [270, 240],
    "bg_footer" => [1200, 300],
    "logo_footer" => [260, 80]
  }.freeze

  private

    def check_image
      return unless image.attached?

      unless image.analyzed?
        attachment_changes["image"].upload
        image.analyze
      end

      unless image.metadata[:width] >= required_width
        errors.add(:image, :image_width, required_width: required_width)
      end

      unless image.metadata[:height] >= required_height
        errors.add(:image, :image_height, required_height: required_height)
      end
    end
end
