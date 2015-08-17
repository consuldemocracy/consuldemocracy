FactoryGirl.define do

  factory :user do
    first_name       'Manuela'
    last_name        'Carmena'
    sequence(:email) { |n| "manuela#{n}@madrid.es" }
    password         'judgmentday'
    confirmed_at     { Time.now }
  end

  factory :debate do
    sequence(:title)     { |n| "Debate #{n} title" }
    description          'Debate description'
    terms_of_service     '1'
    association :author, factory: :user

    trait :hidden do
      hidden_at Time.now
    end
  end

  factory :vote do
    association :votable, factory: :debate
    association :voter,   factory: :user
    vote_flag true
  end

  factory :comment do
    association :commentable, factory: :debate
    user
    body 'Comment body'

    trait :hidden do
      hidden_at Time.now
    end
  end

  factory :administrator do
    user
  end

  factory :moderator do
    user
  end

  factory :organization do
    user
    sequence(:name) { |n| "org#{n}" }
  end

  factory :verified_organization, parent: :organization do
    verified_at { Time.now}
  end

  factory :rejected_organization, parent: :organization do
    rejected_at { Time.now}
  end

  factory :tag, class: 'ActsAsTaggableOn::Tag' do
    sequence(:name) { |n| "Tag #{n} name" }

    trait :featured do
      featured true
    end

    trait :unfeatured do
      featured false
    end
  end

end
