class StatsVersion < ApplicationRecord
  validates :process, presence: true

  belongs_to :process, polymorphic: true
end
