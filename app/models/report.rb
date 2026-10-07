class Report < ApplicationRecord
  KINDS = %i[results stats advanced_stats sensemaking].freeze

  belongs_to :process, polymorphic: true
end
