FactoryGirl.define do
  factory :debate do
    title            'Debate title'
    description      'Debate description'
    terms_of_service '1'
  end

  factory :vote do
    association :votable, factory: :debate
    association :voter, factory: :user
    vote_flag true
  end

end