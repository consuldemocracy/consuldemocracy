class SDG::Phase < ApplicationRecord
  enum kind: %w[sensitization planning monitoring]
  validates :kind, presence: true, uniqueness: true

  def self.[](kind)
    find_by!(kind: kind)
  end
end
