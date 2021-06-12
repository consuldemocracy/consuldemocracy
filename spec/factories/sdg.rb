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
    goal { SDG::Goal[code.split(".")[0]] }
  end

  factory :sdg_phase, class: "SDG::Phase" do
    kind { :sensitization }
  end

  factory :sdg_review, class: "SDG::Review" do
    SDG::Related::RELATABLE_TYPES.map { |relatable_type| relatable_type.downcase.gsub("::", "_") }
    .each do |relatable|
      trait :"#{relatable}_review" do
        association :relatable, factory: relatable
      end
    end
  end
end
