FactoryBot.define do
  factory :visit do
    id { SecureRandom.uuid }
    started_at { DateTime.current }
  end
end
