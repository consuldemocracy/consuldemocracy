class MachineLearningInfo < ApplicationRecord
  def self.for(kind)
    find_by(kind: kind)
  end
end
