FactoryBot.define do
  factory :milestone_status, class: "Milestone::Status" do
    sequence(:name)        { |n| "Milestone status #{n} name" }
    sequence(:description) { |n| "Milestone status #{n} description" }
  end

  factory :milestone do
    association :milestoneable, factory: :budget_investment
    association :status, factory: :milestone_status
    sequence(:title)     { |n| "Milestone #{n} title" }
    description          "Milestone description"
    publication_date     { Date.current }
  end
end
