class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.sample(count = 1)
    if count == 1
      reorder("RANDOM()").first
    else
      reorder("RANDOM()").limit(count)
    end
  end
end
