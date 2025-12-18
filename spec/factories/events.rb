FactoryBot.define do
  factory :event do
    sequence(:name) { |n| "Community Event #{n}" }
    description { "A gathering for the community." }
    event_type { "public_meeting" } # Must be one of the TYPES
    starts_at { 1.day.from_now }
    ends_at { 2.days.from_now }
    location { "Town Hall" }
  end
end
