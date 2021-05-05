class PollOnProject < ApplicationRecord
  belongs_to :project
  belongs_to :poll
end
