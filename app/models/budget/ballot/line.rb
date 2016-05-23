class Budget::Ballot::Line < ActiveRecord::Base
  belongs_to :ballot
  belongs_to :investment
end