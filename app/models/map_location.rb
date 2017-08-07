class MapLocation < ActiveRecord::Base

  belongs_to :proposal
  belongs_to :investment

end
