class Community < ActiveRecord::Base
  has_one :proposal
  has_one :investment
  has_many :topics

end
