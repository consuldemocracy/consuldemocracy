FactoryGirl.define do
  factory :debate do
    title            'Debate title'
    description      'Debate description'
    terms_of_service '1'
  end

  factory :comment do
    commentable
    user
    body 'Comment body'
  end

  factory :commentable do
    debate
  end

end