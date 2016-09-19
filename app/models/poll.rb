class Poll < ActiveRecord::Base
  has_many :booths
  has_many :voters, through: :booths, class_name: "Poll::Voter"
end
