FactoryBot.define do
  factory :milestone_status, class: "Milestone::Status" do
    sequence(:name)        { |n| "Milestone status #{n} name" }
    sequence(:description) { |n| "Milestone status #{n} description" }
  end

  factory :milestone do
    association :milestoneable, factory: :budget_investment
    association :status, factory: :milestone_status
    sequence(:title)     { |n| "Milestone #{n} title" }
    description          { "Milestone description" }
    publication_date     { Date.current }
  end

  factory :progress_bar do
    association :progressable, factory: :budget_investment
    percentage { rand(0..100) }
    kind { :primary }

    trait(:secondary) do
      kind { :secondary }
      sequence(:title) { |n| "Progress bar #{n} title" }
    end
  end
end
