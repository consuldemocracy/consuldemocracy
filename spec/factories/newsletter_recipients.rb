FactoryBot.define do
  factory :newsletter_recipient do
    email { Faker::Internet.email }
    token { Faker::Internet.device_token }

    trait :with_confirmed do
      active { true }
      confirmed_at { Time.zone.now }
    end
  end
end
