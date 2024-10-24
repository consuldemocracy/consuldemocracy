class SDG::Phase < ApplicationRecord
  include Cardable
  enum :kind, { sensitization: 0, planning: 1, monitoring: 2 }
  validates :kind, presence: true, uniqueness: true

  def self.[](kind)
    find_by!(kind: kind)
  end

  def title
    self.class.human_attribute_name("kind.#{kind}")
  end
end
