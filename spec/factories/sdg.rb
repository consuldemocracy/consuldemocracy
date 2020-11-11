FactoryBot.define do
  factory :sdg_goal, class: "SDG::Goal" do
    sequence(:code) { |n| n + 50 }
    sequence(:title) { |n| "Goal #{n + 50}" }
    description "Improve the world in every possible way"
  end
end
