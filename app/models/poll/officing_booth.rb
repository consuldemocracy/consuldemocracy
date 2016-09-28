class Poll
  class OfficingBooth < ActiveRecord::Base
    belongs_to :officer
    belongs_to :booth
  end
end
