class Visit < ApplicationRecord
  alias_attribute :created_at, :started_at
  has_many :ahoy_events, class_name: "Ahoy::Event"
  belongs_to :user
end
