FactoryBot.define do
  factory :tag, class: "ActsAsTaggableOn::Tag" do
    sequence(:name) { |n| "Tag #{n} name" }

    trait :category do
      kind { "category" }
    end

    trait :milestone do
      kind { "milestone" }
    end
  end

  factory :tagging, class: "ActsAsTaggableOn::Tagging" do
    context { "tags" }
    association :taggable, factory: :proposal
    tag
  end

  factory :topic do
    sequence(:title) { |n| "Topic title #{n}" }
    sequence(:description) { |n| "Description as comment #{n}" }
    association :author, factory: :user

    trait :with_community do
      community { create(:proposal).community }
    end

    factory :topic_with_community, traits: [:with_community]
  end

  factory :related_content do
  end
end
