class Report < ApplicationRecord
  KINDS = %i[results stats advanced_stats].freeze

  belongs_to :process, polymorphic: true
end
