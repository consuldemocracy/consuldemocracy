class Report < ApplicationRecord
  KINDS = %i[results stats]

  belongs_to :process, polymorphic: true
end
