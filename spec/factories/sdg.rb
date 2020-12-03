FactoryBot.define do
  factory :sdg_goal, class: "SDG::Goal" do
    sequence(:code) { |n| n }
  end
end
