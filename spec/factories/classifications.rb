FactoryBot.define do
  factory :tag, class: 'ActsAsTaggableOn::Tag' do
    sequence(:name) { |n| "Tag #{n} name" }

    trait :category do
      kind "category"
    end
  end

  factory :topic do
    sequence(:title) { |n| "Topic title #{n}" }
    sequence(:description) { |n| "Description as comment #{n}" }
    association :author, factory: :user
  end

  factory :related_content do
  end
end
