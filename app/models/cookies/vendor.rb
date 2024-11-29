class Cookies::Vendor < ApplicationRecord
  validates :name, presence: true
  validates :cookie, presence: true, uniqueness: true, format: { with: /\A[a-zA-Z0-9\_]+\Z/ }
  validate :cookie_name_collision

  private

    def cookie_name_collision
      if cookie&.starts_with?("cookies_consent")
        errors.add(:cookie, :collision)
      end
    end
end
