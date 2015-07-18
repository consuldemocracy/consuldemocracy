FactoryGirl.define do

  factory :user do
    first_name       'Manuela'
    last_name        'Carmena'
    sequence(:email) { |n| "manuela#{n}@madrid.es" }
    password         'judgmentday'
  end

  factory :debate do
    title            'Debate title'
    description      'Debate description'
    terms_of_service '1'
    association :author, factory: :user
  end

  factory :vote do
    association :votable, factory: :debate
    association :voter, factory: :user
    vote_flag true
  end

end