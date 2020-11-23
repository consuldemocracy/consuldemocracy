FactoryBot.define do
  factory :sdg_goal, class: "SDG::Goal" do
    sequence(:code) { |n| n }
  end

  factory :sdg_target, class: "SDG::Target" do
    sequence(:code, 1) { |n| "#{n}.#{n}" }
  end

  factory :sdg_local_target, class: "SDG::LocalTarget" do
    code                   { "1.1.1" }
    sequence(:title)       { |n| "Local Target #{n} title" }
    sequence(:description) { |n| "Help for Local Target #{n}" }

    target { SDG::Target[code.rpartition(".").first] }
  end
end
