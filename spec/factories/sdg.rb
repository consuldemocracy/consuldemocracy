FactoryBot.define do
  factory :sdg_goal, class: "SDG::Goal" do
    sequence(:code) { |n| n }
    sequence(:title) { |n| "Goal #{n}" }
    description "Improve the world in every possible way"
  end
end
