class ActivePoll < ActiveRecord::Base
  include Measurable

  translates :description, touch: true
  include Globalizable
end
