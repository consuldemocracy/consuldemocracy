class Report < ApplicationRecord
  belongs_to :process, polymorphic: true
end
