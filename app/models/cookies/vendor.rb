class Cookies::Vendor < ApplicationRecord
  validates :name, presence: true
  validates :cookie, presence: true, uniqueness: true, format: { with: /\A[a-zA-Z0-9\_]+\Z/ }
end
