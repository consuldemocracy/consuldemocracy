FactoryBot.define do
  factory :organization do
    user
    responsible_name "Johnny Utah"
    sequence(:name) { |n| "org#{n}" }

    trait :verified do
      verified_at { Time.current }
    end

    trait :rejected do
      rejected_at { Time.current }
    end
  end
end
