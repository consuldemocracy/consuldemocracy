class SDG::Phase < ApplicationRecord
  include Cardable
  enum kind: %w[sensitization planning monitoring]
  validates :kind, presence: true, uniqueness: true

  def self.[](kind)
    find_by!(kind: kind)
  end

  def title
    self.class.human_attribute_name("kind.#{kind}")
  end
end
