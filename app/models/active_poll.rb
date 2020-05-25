class ActivePoll < ApplicationRecord
  include Measurable

  translates :description, touch: true
  include Globalizable
end
