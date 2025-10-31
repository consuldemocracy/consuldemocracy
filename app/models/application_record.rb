class ApplicationRecord < ActiveRecord::Base
  include HumanName
  include SkipValidation

  self.abstract_class = true

  def self.sample(count = 1)
    if count == 1
      reorder(Arel.sql("RANDOM()")).first
    else
      reorder(Arel.sql("RANDOM()")).limit(count)
    end
  end
end
