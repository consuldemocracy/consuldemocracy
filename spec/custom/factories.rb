FactoryBot.define do
  factory :article do
    sequence(:title) { |n| "Titre #{n}" }
    association :author, factory: :user
    content "Article body"

    trait :published do
      status 'published'
    end

    trait :draft do
      status 'draft'
    end

  end

end
