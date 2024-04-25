class Visit < ApplicationRecord
  alias_attribute :created_at, :started_at
  belongs_to :user
end
