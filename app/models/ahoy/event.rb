module Ahoy
  class Event < ApplicationRecord
    self.table_name = "ahoy_events"

    belongs_to :visit
    belongs_to :user
  end
end

# == Schema Information
#
# Table name: ahoy_events
#
#  id         :uuid             not null, primary key
#  visit_id   :uuid
#  user_id    :integer
#  name       :string
#  properties :jsonb
#  time       :datetime
#  ip         :string
#
