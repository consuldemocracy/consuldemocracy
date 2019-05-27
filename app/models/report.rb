class Report < ApplicationRecord
  KINDS = %i[results stats advanced_stats]

  belongs_to :process, polymorphic: true
end
