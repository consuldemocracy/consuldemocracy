FactoryBot.define do
  factory :ahoy_event, class: Ahoy::Event do
    id { SecureRandom.uuid }
    time { DateTime.current }
    sequence(:name) {|n| "Event #{n} type"}
  end

  factory :visit  do
    id { SecureRandom.uuid }
    started_at { DateTime.current }
  end

  factory :campaign do
    sequence(:name) { |n| "Campaign #{n}" }
    sequence(:track_id) { |n| n.to_s }
  end
end
