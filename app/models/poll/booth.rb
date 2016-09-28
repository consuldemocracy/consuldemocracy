class Poll
  class Booth < ActiveRecord::Base
    belongs_to :poll
    has_many :voters

    validates :name, presence: true
  end
end