class Poll
  class Booth < ActiveRecord::Base
    belongs_to :poll
    has_many :voters
  end
end