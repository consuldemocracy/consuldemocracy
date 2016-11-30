class Poll
  class Booth < ActiveRecord::Base
    has_many :voters
    has_many :officing_booths, dependent: :destroy
    has_many :officers, through: :officing_booths

    validates :name, presence: true
  end
end