class Poll
  class Booth < ActiveRecord::Base
    has_many :booth_assigments
    has_many :polls, through: :booth_assigments
    has_many :voters
    has_many :officing_booths, dependent: :destroy
    has_many :officers, through: :officing_booths

    validates :name, presence: true
  end
end