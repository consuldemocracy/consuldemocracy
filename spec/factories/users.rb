FactoryBot.define do
  factory :user do
    sequence(:username) { |n| "Manuela#{n}" }
    sequence(:email)    { |n| "manuela#{n}@consul.dev" }

    password            "judgmentday"
    terms_of_service    "1"
    confirmed_at        { Time.current }
    public_activity     true

    trait :incomplete_verification do
      after :create do |user|
        create(:failed_census_call, user: user)
      end
    end

    trait :level_two do
      residence_verified_at { Time.current }
      unconfirmed_phone "611111111"
      confirmed_phone "611111111"
      sms_confirmation_code "1234"
      document_type "1"
      document_number
      date_of_birth Date.new(1980, 12, 31)
      gender "female"
      geozone
    end

    trait :level_three do
      verified_at { Time.current }
      document_type "1"
      document_number
    end

    trait :hidden do
      hidden_at { Time.current }
    end

    trait :with_confirmed_hide do
      confirmed_hide_at { Time.current }
    end

    trait :verified do
      residence_verified_at { Time.current }
      verified_at { Time.current }
    end

    trait :in_census do
      document_number "12345678Z"
      document_type "1"
      verified_at { Time.current }
    end
  end

  factory :identity do
    user nil
    provider "Twitter"
    uid "MyString"
  end

  factory :administrator do
    user
  end

  factory :moderator do
    user
  end

  factory :valuator do
    user
  end

  factory :manager do
    user
  end

  factory :poll_officer, class: "Poll::Officer" do
    user
  end

  factory :follow do
    association :user, factory: :user

    trait :followed_proposal do
      association :followable, factory: :proposal
    end

    trait :followed_investment do
      association :followable, factory: :budget_investment
    end
  end

  factory :direct_message do
    title    "Hey"
    body     "How are You doing?"
    association :sender,   factory: :user
    association :receiver, factory: :user
  end
end
