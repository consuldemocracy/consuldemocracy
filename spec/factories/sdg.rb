FactoryBot.define do
  factory :sdg_goal, class: "SDG::Goal" do
    sequence(:code) { |n| n }
  end

  factory :sdg_target, class: "SDG::Target" do
    sequence(:code, 1) { |n| "#{n}.#{n}" }
  end
end
