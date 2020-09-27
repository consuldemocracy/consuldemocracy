require "rails_helper"

describe Budget::Investment do
  let(:investment) { build(:budget_investment) }

  describe "Concerns" do
    it_behaves_like "notifiable"
    it_behaves_like "sanitizable"
    it_behaves_like "globalizable", :budget_investment
    it_behaves_like "acts as imageable", :budget_investment_image
    it_behaves_like "acts as paranoid", :budget_investment
  end

  it "is valid" do
    expect(investment).to be_valid
  end

  it "is not valid without an author" do
    investment.author = nil
    expect(investment).not_to be_valid
  end

  describe "#title" do
    it "is not valid without a title" do
      investment.title = nil
      expect(investment).not_to be_valid
    end

    it "is not valid when very short" do
      investment.title = "abc"
      expect(investment).not_to be_valid
    end

    it "is not valid when very long" do
      investment.title = "a" * 81
      expect(investment).not_to be_valid
    end
  end

  it "set correct group and budget ids" do
    budget = create(:budget)
    group_1 = create(:budget_group, budget: budget)
    group_2 = create(:budget_group, budget: budget)

    heading_1 = create(:budget_heading, group: group_1)
    heading_2 = create(:budget_heading, group: group_2)

    investment = create(:budget_investment, heading: heading_1)

    expect(investment.budget_id).to eq budget.id
    expect(investment.group_id).to eq group_1.id

    investment.update!(heading: heading_2)

    expect(investment.budget_id).to eq budget.id
    expect(investment.group_id).to eq group_2.id
  end

  it "logs previous heading value if it is changed" do
    budget = create(:budget, phase: "balloting")

    group = create(:budget_group, budget: budget)

    heading_1 = create(:budget_heading, group: group)
    heading_2 = create(:budget_heading, group: group)

    investment = create(:budget_investment, heading: heading_1)

    expect(investment.previous_heading_id).to eq nil

    investment.update!(heading: heading_2)

    expect(investment.previous_heading_id).to eq heading_1.id
  end

  it "stores original heading id" do
    investment = create(:budget_investment)

    expect(investment.original_heading_id).to eq investment.heading_id
  end

  describe "#unfeasibility_explanation blank" do
    it "is valid if valuation not finished" do
      investment.unfeasibility_explanation = ""
      investment.valuation_finished = false
      expect(investment).to be_valid
    end

    it "is valid if valuation finished and feasible" do
      investment.unfeasibility_explanation = ""
      investment.feasibility = "feasible"
      investment.valuation_finished = true
      expect(investment).to be_valid
    end

    it "is not valid if valuation finished and unfeasible" do
      investment.unfeasibility_explanation = ""
      investment.feasibility = "unfeasible"
      investment.valuation_finished = true
      expect(investment).not_to be_valid
    end
  end

  describe "#price blank" do
    it "is valid if valuation not finished" do
      investment.price = ""
      investment.valuation_finished = false
      expect(investment).to be_valid
    end

    it "is valid if valuation finished and unfeasible" do
      investment.price = ""
      investment.unfeasibility_explanation = "reason"
      investment.feasibility = "unfeasible"
      investment.valuation_finished = true
      expect(investment).to be_valid
    end

    it "is not valid if valuation finished and feasible" do
      investment.price = ""
      investment.feasibility = "feasible"
      investment.valuation_finished = true
      expect(investment).not_to be_valid
    end
  end

  describe "#code" do
    let(:investment) { create(:budget_investment) }

    it "returns the proposal id" do
      expect(investment.code).to include(investment.id.to_s)
    end

    it "returns the administrator id when assigned" do
      investment.administrator = create(:administrator)
      expect(investment.code).to include("#{investment.id}-A#{investment.administrator.id}")
    end
  end

  describe "#send_unfeasible_email" do
    let(:investment) { create(:budget_investment) }

    it "sets the time when the unfeasible email was sent" do
      expect(investment.unfeasible_email_sent_at).not_to be
      investment.send_unfeasible_email
      expect(investment.unfeasible_email_sent_at).to be
    end

    it "send an email" do
      expect { investment.send_unfeasible_email }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end

  describe "#should_show_votes?" do
    it "returns true in selecting phase" do
      budget = create(:budget, :selecting)
      investment = create(:budget_investment, budget: budget)

      expect(investment.should_show_votes?).to eq(true)
    end

    it "returns false in any other phase" do
      Budget::Phase::PHASE_KINDS.reject { |phase| phase == "selecting" }.each do |phase|
        budget = create(:budget, phase: phase)
        investment = create(:budget_investment, budget: budget)

        expect(investment.should_show_votes?).to eq(false)
      end
    end
  end

  describe "#should_show_vote_count?" do
    it "returns true in valuating phase" do
      budget = create(:budget, :valuating)
      investment = create(:budget_investment, budget: budget)

      expect(investment.should_show_vote_count?).to eq(true)
    end

    it "returns false in any other phase" do
      Budget::Phase::PHASE_KINDS.reject { |phase| phase == "valuating" }.each do |phase|
        budget = create(:budget, phase: phase)
        investment = create(:budget_investment, budget: budget)

        expect(investment.should_show_vote_count?).to eq(false)
      end
    end
  end

  describe "#should_show_ballots?" do
    it "returns true in balloting phase for selected investments" do
      budget = create(:budget, :balloting)
      investment = create(:budget_investment, :selected, budget: budget)

      expect(investment.should_show_ballots?).to eq(true)
    end

    it "returns false for unselected investments" do
      budget = create(:budget, :balloting)
      investment = create(:budget_investment, :unselected, budget: budget)

      expect(investment.should_show_ballots?).to eq(false)
    end

    it "returns false in any other phase" do
      Budget::Phase::PHASE_KINDS.reject { |phase| phase == "balloting" }.each do |phase|
        budget = create(:budget, phase: phase)
        investment = create(:budget_investment, :selected, budget: budget)

        expect(investment.should_show_ballots?).to eq(false)
      end
    end
  end

  describe "#should_show_price?" do
    let(:budget) { create(:budget, :publishing_prices) }
    let(:investment) do
      create(:budget_investment, :selected, budget: budget)
    end

    it "returns true for selected investments which budget's phase is publishing_prices or later" do
      Budget::Phase::PUBLISHED_PRICES_PHASES.each do |phase|
        budget.update!(phase: phase)

        expect(investment.should_show_price?).to eq(true)
      end
    end

    it "returns false in any other phase" do
      (Budget::Phase::PHASE_KINDS - Budget::Phase::PUBLISHED_PRICES_PHASES).each do |phase|
        budget.update!(phase: phase)

        expect(investment.should_show_price?).to eq(false)
      end
    end

    it "returns false if investment is not selected" do
      investment.selected = false

      expect(investment.should_show_price?).to eq(false)
    end

    it "returns false if price is not present" do
      investment.price = nil

      expect(investment.should_show_price?).to eq(false)
    end
  end

  describe "#should_show_price_explanation?" do
    let(:budget) { create(:budget, :publishing_prices) }
    let(:investment) do
      create(:budget_investment, :selected, budget: budget, price_explanation: "because of reasons")
    end

    it "returns true for selected with price_explanation & budget in publishing_prices or later" do
      Budget::Phase::PUBLISHED_PRICES_PHASES.each do |phase|
        budget.update!(phase: phase)

        expect(investment.should_show_price_explanation?).to eq(true)
      end
    end

    it "returns false in any other phase" do
      (Budget::Phase::PHASE_KINDS - Budget::Phase::PUBLISHED_PRICES_PHASES).each do |phase|
        budget.update!(phase: phase)

        expect(investment.should_show_price_explanation?).to eq(false)
      end
    end

    it "returns false if investment is not selected" do
      investment.selected = false

      expect(investment.should_show_price_explanation?).to eq(false)
    end

    it "returns false if price_explanation is not present" do
      investment.price_explanation = ""

      expect(investment.should_show_price_explanation?).to eq(false)
    end
  end

  describe "#should_show_unfeasibility_explanation?" do
    let(:budget) { create(:budget) }
    let(:investment) do
      create(:budget_investment, :unfeasible, :finished, budget: budget)
    end

    it "returns true for unfeasible investments with unfeasibility explanation and valuation finished" do
      Budget::Phase::PUBLISHED_PRICES_PHASES.each do |phase|
        budget.update!(phase: phase)

        expect(investment.should_show_unfeasibility_explanation?).to eq(true)
      end
    end

    it "returns false in valuation has not finished" do
      investment.update!(valuation_finished: false)
      Budget::Phase::PUBLISHED_PRICES_PHASES.each do |phase|
        budget.update!(phase: phase)

        expect(investment.should_show_unfeasibility_explanation?).to eq(false)
      end
    end

    it "returns false if not unfeasible" do
      investment.update!(feasibility: "undecided")
      Budget::Phase::PUBLISHED_PRICES_PHASES.each do |phase|
        budget.update!(phase: phase)

        expect(investment.should_show_unfeasibility_explanation?).to eq(false)
      end
    end

    it "returns false if unfeasibility explanation blank" do
      investment.unfeasibility_explanation = ""
      Budget::Phase::PUBLISHED_PRICES_PHASES.each do |phase|
        budget.update!(phase: phase)

        expect(investment.should_show_unfeasibility_explanation?).to eq(false)
      end
    end
  end

  describe "#by_budget" do
    it "returns investments scoped by budget" do
      budget1 = create(:budget)
      budget2 = create(:budget)

      group1 = create(:budget_group, budget: budget1)
      group2 = create(:budget_group, budget: budget2)

      heading1 = create(:budget_heading, group: group1)
      heading2 = create(:budget_heading, group: group2)

      investment1 = create(:budget_investment, heading: heading1)
      investment2 = create(:budget_investment, heading: heading1)
      investment3 = create(:budget_investment, heading: heading2)

      investments_by_budget = Budget::Investment.by_budget(budget1)

      expect(investments_by_budget).to match_array [investment1, investment2]
      expect(investments_by_budget).not_to include investment3
    end
  end

  describe "#by_admin" do
    it "returns investments assigned to specific administrator" do
      investment1 = create(:budget_investment, administrator_id: 33)
      create(:budget_investment)

      by_admin = Budget::Investment.by_admin(33)

      expect(by_admin).to eq [investment1]
    end
  end

  describe "by_valuator" do
    it "returns investments assigned to a valuator" do
      alfred = create(:valuator)
      batman = create(:valuator)

      manor = create(:budget_investment, valuators: [alfred])
      batcave = create(:budget_investment, valuators: [alfred, batman])

      by_valuator = Budget::Investment.by_valuator(alfred)

      expect(by_valuator).to match_array [manor, batcave]
    end

    it "does not return investments assigned to a different valuator" do
      jekyll = create(:valuator)
      hyde = create(:valuator)

      create(:budget_investment, valuators: [hyde])

      by_valuator = Budget::Investment.by_valuator(jekyll)

      expect(by_valuator).to be_empty
    end
  end

  describe "#by_valuator_group" do
    let(:aquaman)        { create(:valuator) }
    let(:justice_league) { create(:valuator_group, valuators: [aquaman]) }

    it "returns investments assigned to a valuator's group" do
      water_power = create(:budget_investment, valuator_groups: [justice_league], valuators: [aquaman])
      solar_power = create(:budget_investment, valuator_groups: [justice_league])

      by_valuator_group = Budget::Investment.by_valuator_group(justice_league)

      expect(by_valuator_group).to contain_exactly(solar_power, water_power)
    end

    it "does not return investments assigned to no groups" do
      create(:budget_investment, valuators: [aquaman], valuator_groups: [])

      expect(Budget::Investment.by_valuator_group(justice_league)).to be_empty
    end

    it "does not return investments assigned to a different group" do
      create(:budget_investment, valuators: [aquaman], valuator_groups: [create(:valuator_group)])

      expect(Budget::Investment.by_valuator_group(justice_league)).to be_empty
    end
  end

  describe ".scoped_filter" do
    let(:budget)     { create(:budget, :balloting, slug: "budget_slug") }
    let(:investment) { create(:budget_investment, budget: budget) }

    it "finds budget by id or slug" do
      results = Budget::Investment.scoped_filter({ budget_id: budget.id }, nil)

      expect(results).to eq [investment]

      results = Budget::Investment.scoped_filter({ budget_id: "budget_slug" }, nil)

      expect(results).to eq [investment]
    end

    it "does not raise error if budget is not found" do
      result = Budget::Investment.scoped_filter({ budget_id: "wrong_budget" }, nil)
      expect(result).to be_empty
    end

    describe "with without_admin filter" do
      let(:params) { { advanced_filters: ["without_admin"], budget_id: budget.id } }
      it "returns only investment without admin" do
        create(:budget_investment,
               :with_administrator,
               budget: budget)
        investment2 = create(:budget_investment, budget: budget)

        expect(Budget::Investment.scoped_filter(params, "all")).to eq([investment2])
      end
    end

    describe "with without_valuator filter" do
      let(:params) { { advanced_filters: ["without_valuator"], budget_id: budget.id } }
      it "returns only investment without valuator" do
        create(:budget_investment,
               :with_valuator,
               budget: budget)
        investment2 = create(:budget_investment,
                             :with_administrator,
                             budget: budget)
        investment3 = create(:budget_investment,
                             budget: budget)

        expect(Budget::Investment.scoped_filter(params, "all"))
          .to contain_exactly(investment2, investment3)
      end
    end

    describe "with under_valuation filter" do
      let(:params) { { advanced_filters: ["under_valuation"], budget_id: budget.id } }
      it "returns only investment under valuation" do
        investment1 = create(:budget_investment, :with_administrator, :open, :with_valuator,
                             budget: budget)
        create(:budget_investment, :with_administrator, budget: budget)
        create(:budget_investment, budget: budget)

        expect(Budget::Investment.scoped_filter(params, "all")).to eq([investment1])
      end
    end

    describe "with valuation_finished filter" do
      let(:params) { { advanced_filters: ["valuation_finished"], budget_id: budget.id } }
      it "returns only investment with valuation finished" do
        investment1 = create(:budget_investment,
                             :selected,
                             budget: budget)
        create(:budget_investment,
               :with_administrator,
               budget: budget)
        create(:budget_investment,
               budget: budget)

        expect(Budget::Investment.scoped_filter(params, "all")).to eq([investment1])
      end
    end

    describe "with winners filter" do
      let(:params) { { advanced_filters: ["winners"], budget_id: budget.id } }
      it "returns only investment winners" do
        investment1 = create(:budget_investment, :winner, :finished, budget: budget)
        create(:budget_investment, :with_administrator, budget: budget)
        create(:budget_investment, budget: budget)

        expect(Budget::Investment.scoped_filter(params, "all")).to eq([investment1])
      end
    end
  end

  describe "scopes" do
    describe "valuation_open" do
      it "returns investments with valuation open" do
        investment = create(:budget_investment, valuation_finished: false)

        expect(Budget::Investment.valuation_open).to eq [investment]
      end

      it "does not return investments with valuation finished" do
        create(:budget_investment, valuation_finished: true)

        expect(Budget::Investment.valuation_open).to be_empty
      end
    end

    describe "valuation_finished" do
      it "returns investments with valuation finished" do
        investment = create(:budget_investment, valuation_finished: true)

        expect(Budget::Investment.valuation_finished).to eq [investment]
      end

      it "does not return investments with valuation open" do
        create(:budget_investment, valuation_finished: false)

        expect(Budget::Investment.valuation_finished).to be_empty
      end
    end

    describe "without_admin" do
      it "returns investments without an admin" do
        investment = create(:budget_investment, :finished, administrator: nil)

        expect(Budget::Investment.without_admin).to eq [investment]
      end

      it "does not return investments with an admin" do
        create(:budget_investment, :with_administrator)

        expect(Budget::Investment.without_admin).to be_empty
      end
    end

    describe "managed" do
      it "returns open investments with assigned admin but without assigned valuators" do
        investment = create(:budget_investment, :with_administrator)

        expect(Budget::Investment.managed).to eq [investment]
      end

      it "does not return investments without assigned admin" do
        create(:budget_investment, administrator: nil)

        expect(Budget::Investment.managed).to be_empty
      end

      it "does not return investments with assigned valuator" do
        create(:budget_investment, :with_administrator, :with_valuator)

        expect(Budget::Investment.managed).to be_empty
      end

      it "does not return finished investments" do
        create(:budget_investment, :with_administrator, :finished)

        expect(Budget::Investment.managed).to be_empty
      end
    end

    describe "valuating" do
      it "returns investments with assigned valuator but valuation not finished" do
        investment = create(:budget_investment, :open, :with_valuator)

        expect(Budget::Investment.valuating).to eq [investment]
      end

      it "returns investments with assigned valuator groups but valuation not finished" do
        investment = create(:budget_investment, :open, valuator_groups: [create(:valuator_group)])

        expect(Budget::Investment.valuating).to eq [investment]
      end

      it "does not return investments with valuation finished" do
        create(:budget_investment, :finished, :with_valuator)
        create(:budget_investment, :finished, valuator_groups: [create(:valuator_group)])

        expect(Budget::Investment.valuating).to be_empty
      end

      it "does not return investments without valuator nor valuator group" do
        create(:budget_investment, :open)

        expect(Budget::Investment.valuating).to be_empty
      end
    end

    describe "feasible" do
      it "returns feasible investments" do
        feasible_investment = create(:budget_investment, :feasible)

        expect(Budget::Investment.feasible).to eq [feasible_investment]
      end

      it "does not return unfeasible nor undecided investments" do
        create(:budget_investment, :undecided)
        create(:budget_investment, :unfeasible)

        expect(Budget::Investment.feasible).to be_empty
      end
    end

    describe "unfeasible" do
      it "returns unfeasible investments" do
        unfeasible_investment = create(:budget_investment, :unfeasible)

        expect(Budget::Investment.unfeasible).to eq [unfeasible_investment]
      end

      it "does not return feasible nor undecided investments" do
        create(:budget_investment, :feasible)
        create(:budget_investment, :undecided)

        expect(Budget::Investment.unfeasible).to be_empty
      end
    end

    describe "not_unfeasible" do
      it "returns feasible and undecided investments" do
        undecided_investment = create(:budget_investment, :undecided)
        feasible_investment = create(:budget_investment, :feasible)

        expect(Budget::Investment.not_unfeasible).to match_array [undecided_investment, feasible_investment]
      end

      it "does not return unfeasible investments" do
        create(:budget_investment, :unfeasible)

        expect(Budget::Investment.not_unfeasible).to be_empty
      end
    end

    describe "undecided" do
      it "returns undecided investments" do
        undecided_investment = create(:budget_investment, :undecided)

        expect(Budget::Investment.undecided).to eq [undecided_investment]
      end

      it "does not return feasible nor unfeasible investments" do
        create(:budget_investment, :feasible)
        create(:budget_investment, :unfeasible)

        expect(Budget::Investment.undecided).to be_empty
      end
    end

    describe "selected" do
      it "returns selected investments" do
        selected_investment = create(:budget_investment, :selected)

        expect(Budget::Investment.selected).to eq [selected_investment]
      end

      it "does not return unselected investments" do
        create(:budget_investment, :unselected)

        expect(Budget::Investment.selected).to be_empty
      end
    end

    describe "unselected" do
      it "returns all unselected not_unfeasible investments" do
        unselected_undecided_investment = create(:budget_investment, :unselected, :undecided)
        unselected_feasible_investment = create(:budget_investment, :unselected, :feasible)

        expect(Budget::Investment.unselected).to match_array [unselected_undecided_investment, unselected_feasible_investment]
      end

      it "does not return selected investments" do
        create(:budget_investment, :selected)

        expect(Budget::Investment.unselected).to be_empty
      end

      it "does not return unfeasible investments" do
        create(:budget_investment, :unselected, :unfeasible)

        expect(Budget::Investment.unselected).to be_empty
      end
    end

    describe "sort_by_title" do
      it "sorts using the title in the current locale" do
        create(:budget_investment, title_en: "CCCC", title_es: "BBBB", description_en: "CCCC", description_es: "BBBB")
        create(:budget_investment, title_en: "DDDD", title_es: "AAAA", description_en: "DDDD", description_es: "AAAA")

        expect(Budget::Investment.sort_by_title.map(&:title)).to eq %w[CCCC DDDD]
      end

      it "takes into consideration title fallbacks when there is no translation for current locale" do
        create(:budget_investment, title: "BBBB")
        I18n.with_locale(:es) do
          create(:budget_investment, title: "AAAA")
        end

        expect(Budget::Investment.sort_by_title.map(&:title)).to eq %w[AAAA BBBB]
      end
    end

    describe "search_by_title_or_id" do
      it "does not return investments by description" do
        create(:budget_investment, title: "Something", description: "Awesome")

        expect(Budget::Investment.search_by_title_or_id("Awesome")).to be_empty
      end

      it "returns investment by given id" do
        investment = create(:budget_investment)

        expect(Budget::Investment.search_by_title_or_id(investment.id.to_s)).to eq([investment])
      end

      it "returns investments by given title" do
        investment = create(:budget_investment, title: "Investment title")

        expect(Budget::Investment.search_by_title_or_id("Investment title")).to eq([investment])
      end

      it "finds investments with numbers in their title" do
        investment = create(:budget_investment, title: "99 red balloons")

        expect(Budget::Investment.search_by_title_or_id("99")).to eq([investment])
      end
    end
  end

  describe "apply_filters_and_search" do
    let(:budget) { create(:budget) }

    it "returns feasible investments" do
      investment1 = create(:budget_investment, :feasible,   budget: budget)
      investment2 = create(:budget_investment, :feasible,   budget: budget)
      investment3 = create(:budget_investment, :unfeasible, budget: budget)

      results = Budget::Investment.apply_filters_and_search(budget, {}, :feasible)

      expect(results).to     include investment1
      expect(results).to     include investment2
      expect(results).not_to include investment3
    end

    it "returns unfeasible investments" do
      investment1 = create(:budget_investment, :unfeasible, budget: budget)
      investment2 = create(:budget_investment, :unfeasible, budget: budget)
      investment3 = create(:budget_investment, :feasible,   budget: budget)

      results = Budget::Investment.apply_filters_and_search(budget, {}, :unfeasible)

      expect(results).to     include investment1
      expect(results).to     include investment2
      expect(results).not_to include investment3
    end

    it "returns selected investments" do
      budget.update!(phase: "balloting")

      investment1 = create(:budget_investment, :feasible, :selected,   budget: budget)
      investment2 = create(:budget_investment, :feasible, :selected,   budget: budget)
      investment3 = create(:budget_investment, :feasible, :unselected, budget: budget)

      results = Budget::Investment.apply_filters_and_search(budget, {}, :selected)

      expect(results).to     include investment1
      expect(results).to     include investment2
      expect(results).not_to include investment3
    end

    it "returns unselected investments" do
      budget.update!(phase: "balloting")

      investment1 = create(:budget_investment, :feasible, :unselected, budget: budget)
      investment2 = create(:budget_investment, :feasible, :unselected, budget: budget)
      investment3 = create(:budget_investment, :feasible, :selected,   budget: budget)

      results = Budget::Investment.apply_filters_and_search(budget, {}, :unselected)

      expect(results).to     include investment1
      expect(results).to     include investment2
      expect(results).not_to include investment3
    end

    it "returns investmens by heading" do
      group = create(:budget_group, budget: budget)

      heading1 = create(:budget_heading, group: group)
      heading2 = create(:budget_heading, group: group)

      investment1 = create(:budget_investment, heading: heading1)
      investment2 = create(:budget_investment, heading: heading1)
      investment3 = create(:budget_investment, heading: heading2)

      results = Budget::Investment.apply_filters_and_search(budget, heading_id: heading1.id)

      expect(results).to     include investment1
      expect(results).to     include investment2
      expect(results).not_to include investment3
    end

    it "returns investments by search string" do
      investment1 = create(:budget_investment, title: "health for all",  budget: budget)
      investment2 = create(:budget_investment, title: "improved health", budget: budget)
      investment3 = create(:budget_investment, title: "finance",         budget: budget)

      results = Budget::Investment.apply_filters_and_search(budget, search: "health")

      expect(results).to match_array [investment1, investment2]
      expect(results).not_to include investment3
    end
  end

  describe "search" do
    context "attributes" do
      let(:attributes) do
        { title: "save the world",
          description: "in order to save the world one must think about...",
          title_es: "para salvar el mundo uno debe pensar en...",
          description_es: "uno debe pensar" }
      end

      it "searches by title" do
        budget_investment = create(:budget_investment, attributes)
        results = Budget::Investment.search("save the world")
        expect(results).to eq([budget_investment])
      end

      it "searches by title across all languages" do
        budget_investment = create(:budget_investment, attributes)
        results = Budget::Investment.search("salvar el mundo")
        expect(results).to eq([budget_investment])
      end

      it "searches by author name" do
        author = create(:user, username: "Danny Trejo")
        budget_investment = create(:budget_investment, author: author)
        results = Budget::Investment.search("Danny")
        expect(results).to eq([budget_investment])
      end
    end

    context "tags" do
      it "searches by tags" do
        investment = create(:budget_investment, tag_list: "Latina")

        results = Budget::Investment.search("Latina")
        expect(results.first).to eq(investment)

        results = Budget::Investment.search("Latin")
        expect(results.first).to eq(investment)
      end

      it "gets and sets valuation tags through virtual attributes" do
        investment = create(:budget_investment)

        investment.valuation_tag_list = %w[Code Test Refactor]

        expect(investment.valuation_tag_list).to match_array(%w[Code Test Refactor])
      end

      describe ".by_tag" do
        it "does not return duplicate records for tags in different contexts" do
          investment = create(:budget_investment, tag_list: ["Same"], valuation_tag_list: ["Same"])

          expect(Budget::Investment.by_tag("Same")).to eq [investment]
        end
      end
    end
  end

  describe "Permissions" do
    let(:budget)      { create(:budget) }
    let(:group)       { create(:budget_group, budget: budget) }
    let(:heading)     { create(:budget_heading, group: group) }
    let(:user)        { create(:user, :level_two) }
    let(:luser)       { create(:user) }
    let(:district_sp) { create(:budget_investment, budget: budget, heading: heading) }

    describe "#reason_for_not_being_selectable_by" do
      it "rejects not logged in users" do
        expect(district_sp.reason_for_not_being_selectable_by(nil)).to eq(:not_logged_in)
      end

      it "rejects not verified users" do
        expect(district_sp.reason_for_not_being_selectable_by(luser)).to eq(:not_verified)
      end

      it "rejects organizations" do
        create(:organization, user: user)
        expect(district_sp.reason_for_not_being_selectable_by(user)).to eq(:organization)
      end

      it "rejects selections when selecting is not allowed (via admin setting)" do
        budget.phase = "reviewing"
        expect(district_sp.reason_for_not_being_selectable_by(user)).to eq(:no_selecting_allowed)
      end

      it "accepts valid selections when selecting is allowed" do
        budget.phase = "selecting"
        expect(district_sp.reason_for_not_being_selectable_by(user)).to be_nil
      end

      it "rejects votes in two headings of the same group" do
        carabanchel = create(:budget_heading, group: group)
        salamanca   = create(:budget_heading, group: group)

        create(:budget_investment, heading: carabanchel, voters: [user])

        salamanca_investment = create(:budget_investment, heading: salamanca)

        expect(salamanca_investment.valid_heading?(user)).to eq(false)
      end

      it "accepts votes in multiple headings of the same group" do
        group.update!(max_votable_headings: 2)
        carabanchel = create(:budget_heading, group: group)
        salamanca   = create(:budget_heading, group: group)

        create(:budget_investment, heading: carabanchel, voters: [user])

        salamanca_investment = create(:budget_investment, heading: salamanca)

        expect(salamanca_investment.valid_heading?(user)).to eq(true)
      end

      it "accepts votes in any heading previously voted in" do
        group.update!(max_votable_headings: 2)

        carabanchel = create(:budget_heading, group: group)
        salamanca   = create(:budget_heading, group: group)

        carabanchel_investment = create(:budget_investment, heading: carabanchel, voters: [user])
        salamanca_investment   = create(:budget_investment, heading: salamanca, voters: [user])

        expect(carabanchel_investment.valid_heading?(user)).to eq(true)
        expect(salamanca_investment.valid_heading?(user)).to eq(true)
      end

      it "allows votes in a group with a single heading" do
        all_city_investment = create(:budget_investment, heading: heading)

        expect(all_city_investment.valid_heading?(user)).to eq(true)
      end

      it "allows votes in a group with a single heading after voting in that heading" do
        create(:budget_investment, heading: heading, voters: [user])

        investment_for_same_heading = create(:budget_investment, heading: heading)

        expect(investment_for_same_heading.valid_heading?(user)).to eq(true)
      end

      it "allows votes in a group with a single heading after voting in another group" do
        districts = create(:budget_group, budget: budget)
        carabanchel = create(:budget_heading, group: districts)

        create(:budget_investment, heading: carabanchel, voters: [user])

        investment_from_different_group = create(:budget_investment, heading: heading)

        expect(investment_from_different_group.valid_heading?(user)).to eq(true)
      end

      it "allows votes in a group with multiple headings after voting in group with a single heading" do
        districts = create(:budget_group, budget: budget)
        2.times { create(:budget_heading, group: districts) }

        create(:budget_investment, heading: heading, voters: [user])

        investment = create(:budget_investment, heading: districts.headings.sample)

        expect(investment.valid_heading?(user)).to eq(true)
      end

      describe "#can_vote_in_another_heading?" do
        let(:districts)   { create(:budget_group, budget: budget) }
        let(:carabanchel) { create(:budget_heading, group: districts) }
        let(:salamanca)   { create(:budget_heading, group: districts) }
        let(:latina)      { create(:budget_heading, group: districts) }

        let(:carabanchel_investment) { create(:budget_investment, heading: carabanchel) }
        let(:salamanca_investment)   { create(:budget_investment, heading: salamanca) }
        let(:latina_investment)      { create(:budget_investment, heading: latina) }

        it "returns true if the user has voted in less headings than the maximum" do
          districts.update!(max_votable_headings: 2)

          create(:vote, votable: carabanchel_investment, voter: user)

          expect(salamanca_investment.can_vote_in_another_heading?(user)).to eq(true)
        end

        it "returns false if the user has already voted in the maximum number of headings" do
          districts.update!(max_votable_headings: 2)

          create(:vote, votable: carabanchel_investment, voter: user)
          create(:vote, votable: salamanca_investment, voter: user)

          expect(latina_investment.can_vote_in_another_heading?(user)).to eq(false)
        end
      end
    end
  end

  describe "#voted_in?" do
    let(:user) { create(:user) }
    let(:investment) { create(:budget_investment) }

    it "returns true if the user has voted in this heading" do
      create(:vote, votable: investment, voter: user)

      expect(investment.voted_in?(investment.heading, user)).to eq(true)
    end

    it "returns false if the user has not voted in this heading" do
      expect(investment.voted_in?(investment.heading, user)).to eq(false)
    end
  end

  describe "Order" do
    describe "#sort_by_confidence_score" do
      it "orders by confidence_score" do
        least_voted = create(:budget_investment, cached_votes_up: 1)
        most_voted = create(:budget_investment, cached_votes_up: 10)
        some_votes = create(:budget_investment, cached_votes_up: 5)

        expect(Budget::Investment.sort_by_confidence_score).to eq [most_voted, some_votes, least_voted]
      end

      it "orders by confidence_score and then by id" do
        least_voted  = create(:budget_investment, cached_votes_up: 1)
        most_voted   = create(:budget_investment, cached_votes_up: 10)
        most_voted2  = create(:budget_investment, cached_votes_up: 10)
        least_voted2 = create(:budget_investment, cached_votes_up: 1)

        expect(Budget::Investment.sort_by_confidence_score).to eq [
          most_voted2, most_voted, least_voted2, least_voted
        ]
      end
    end
  end

  describe "responsible_name" do
    let(:user) { create(:user, document_number: "123456") }
    let!(:investment) { create(:budget_investment, author: user) }

    it "gets updated with the document_number" do
      expect(investment.responsible_name).to eq("123456")
    end

    it "does not get updated if the user is erased" do
      user.erase
      user.update!(document_number: nil)
      expect(user.document_number).to be_blank
      investment.valid?
      expect(investment.responsible_name).to eq("123456")
    end
  end

  describe "total votes" do
    it "takes into account physical votes in addition to web votes" do
      budget = create(:budget, :selecting)
      investment = create(:budget_investment, budget: budget)

      investment.register_selection(create(:user, :level_two))
      expect(investment.total_votes).to eq(1)

      investment.physical_votes = 10
      expect(investment.total_votes).to eq(11)
    end
  end

  describe "#with_supports" do
    it "returns proposals with supports" do
      inv1 = create(:budget_investment, voters: [create(:user)])
      inv2 = create(:budget_investment)

      expect(Budget::Investment.with_supports).to eq [inv1]
      expect(Budget::Investment.with_supports).not_to include(inv2)
    end
  end

  describe "Final Voting" do
    describe "Permissions" do
      let(:budget)      { create(:budget) }
      let(:heading)     { create(:budget_heading, budget: budget) }
      let(:user)        { create(:user, :level_two) }
      let(:luser)       { create(:user) }
      let(:ballot)      { create(:budget_ballot, budget: budget) }
      let(:investment)  { create(:budget_investment, :selected, budget: budget, heading: heading) }

      describe "#reason_for_not_being_ballotable_by" do
        it "rejects not logged in users" do
          expect(investment.reason_for_not_being_ballotable_by(nil, ballot)).to eq(:not_logged_in)
        end

        it "rejects not verified users" do
          expect(investment.reason_for_not_being_ballotable_by(luser, ballot)).to eq(:not_verified)
        end

        it "rejects organizations" do
          create(:organization, user: user)
          expect(investment.reason_for_not_being_ballotable_by(user, ballot)).to eq(:organization)
        end

        it "rejects votes when voting is not allowed (wrong phase)" do
          budget.phase = "reviewing"
          expect(investment.reason_for_not_being_ballotable_by(user, ballot)).to eq(:no_ballots_allowed)
        end

        it "rejects non-selected investments" do
          investment.selected = false
          expect(investment.reason_for_not_being_ballotable_by(user, ballot)).to eq(:not_selected)
        end

        it "accepts valid ballots when voting is allowed" do
          budget.phase = "balloting"
          expect(investment.reason_for_not_being_ballotable_by(user, ballot)).to be_nil
        end

        it "accepts valid selections" do
          budget.phase = "selecting"
          expect(investment.reason_for_not_being_selectable_by(user)).to be_nil
        end

        it "rejects users with different headings" do
          budget.phase = "balloting"
          group = create(:budget_group, budget: budget)
          california = create(:budget_heading, group: group)
          new_york = create(:budget_heading, group: group)

          inv1 = create(:budget_investment, :selected, budget: budget, heading: california)
          inv2 = create(:budget_investment, :selected, budget: budget, heading: new_york)
          ballot = create(:budget_ballot, user: user, budget: budget, investments: [inv1])

          expect(inv2.reason_for_not_being_ballotable_by(user, ballot)).to eq(:different_heading_assigned)
        end

        it "rejects proposals with price higher than current available money" do
          budget.phase = "balloting"
          districts = create(:budget_group, budget: budget)
          carabanchel = create(:budget_heading, group: districts, price: 35)
          inv1 = create(:budget_investment, :selected, budget: budget, heading: carabanchel, price: 30)
          inv2 = create(:budget_investment, :selected, budget: budget, heading: carabanchel, price: 10)

          ballot = create(:budget_ballot, user: user, budget: budget, investments: [inv1])

          expect(inv2.reason_for_not_being_ballotable_by(user, ballot)).to eq(:not_enough_money)
        end

        context "Approval voting" do
          before { budget.update!(phase: "balloting", voting_style: "approval") }
          let(:group) { create(:budget_group, budget: budget) }

          it "does not reject investments based on available money" do
            heading = create(:budget_heading, group: group, max_ballot_lines: 2)
            inv1 = create(:budget_investment, :selected, heading: heading, price: heading.price)
            inv2 = create(:budget_investment, :selected, heading: heading, price: heading.price)
            ballot = create(:budget_ballot, user: user, budget: budget, investments: [inv1])

            expect(inv2.reason_for_not_being_ballotable_by(user, ballot)).to be nil
          end

          it "rejects if not enough available votes" do
            heading = create(:budget_heading, group: group, max_ballot_lines: 1)
            inv1 = create(:budget_investment, :selected, heading: heading)
            inv2 = create(:budget_investment, :selected, heading: heading)
            ballot = create(:budget_ballot, user: user, budget: budget, investments: [inv1])

            reason = inv2.reason_for_not_being_ballotable_by(user, ballot)

            expect(reason).to eq(:not_enough_available_votes)
          end
        end
      end
    end
  end

  describe "Reclassification" do
    let(:budget)   { create(:budget, :balloting)   }
    let(:group)    { create(:budget_group, budget: budget) }
    let(:heading1) { create(:budget_heading, group: group) }
    let(:heading2) { create(:budget_heading, group: group) }

    describe "saved_change_to_heading?" do
      it "returns true if budget is in balloting phase and heading has changed" do
        investment = create(:budget_investment, heading: heading1)
        investment.update!(heading: heading2)

        expect(investment.saved_change_to_heading?).to eq(true)
      end

      it "returns false if heading has not changed" do
        investment = create(:budget_investment, heading: heading1)
        investment.update!(heading: heading1)

        expect(investment.saved_change_to_heading?).to eq(false)
      end

      it "returns false if budget is not balloting phase" do
        Budget::Phase::PHASE_KINDS.reject { |phase| phase == "balloting" }.each do |phase|
          budget.update!(phase: phase)
          investment = create(:budget_investment, heading: heading1)

          investment.update!(heading: heading2)

          expect(investment.saved_change_to_heading?).to eq(false)
        end
      end
    end

    describe "log_heading_change" do
      it "stores the previous heading before being reclassified" do
        investment = create(:budget_investment, heading: heading1)

        expect(investment.heading_id).to eq(heading1.id)
        expect(investment.previous_heading_id).to eq(nil)

        investment.heading = heading2
        investment.save!

        investment.reload
        expect(investment.heading_id).to eq(heading2.id)
        expect(investment.previous_heading_id).to eq(heading1.id)
      end
    end

    describe "store_reclassified_votes" do
      it "stores the votes for a reclassified investment" do
        investment = create(:budget_investment, :selected, heading: heading1)

        3.times { create(:user, ballot_lines: [investment]) }

        expect(investment.ballot_lines_count).to eq(3)

        investment.heading = heading2
        investment.store_reclassified_votes("heading_changed")

        reclassified_vote = Budget::ReclassifiedVote.first

        expect(Budget::ReclassifiedVote.count).to eq(3)
        expect(reclassified_vote.investment_id).to eq(investment.id)
        expect(reclassified_vote.user_id).to eq(Budget::Ballot.first.user.id)
        expect(reclassified_vote.reason).to eq("heading_changed")
      end
    end

    describe "remove_reclassified_votes" do
      it "removes votes from invesment" do
        investment = create(:budget_investment, :selected, heading: heading1)

        3.times { create(:user, ballot_lines: [investment]) }

        expect(investment.ballot_lines_count).to eq(3)

        investment.heading = heading2
        investment.remove_reclassified_votes

        investment.reload
        expect(investment.ballot_lines_count).to eq(0)
      end
    end

    describe "check_for_reclassification" do
      it "stores reclassfied votes and removes actual votes if an investment has been reclassified" do
        investment = create(:budget_investment, :selected, heading: heading1)

        3.times { create(:user, ballot_lines: [investment]) }

        expect(investment.ballot_lines_count).to eq(3)

        investment.heading = heading2
        investment.save!
        investment.reload

        expect(investment.ballot_lines_count).to eq(0)
        expect(Budget::ReclassifiedVote.count).to eq(3)
      end

      it "does not store reclassified votes nor remove actual votes if the investment has not been reclassifed" do
        investment = create(:budget_investment, :selected, heading: heading1)

        3.times { create(:user, ballot_lines: [investment]) }

        expect(investment.ballot_lines_count).to eq(3)

        investment.save!
        investment.reload

        expect(investment.ballot_lines_count).to eq(3)
        expect(Budget::ReclassifiedVote.count).to eq(0)
      end
    end
  end

  describe "admin_and_valuator_users_associated" do
    let(:investment) { create(:budget_investment) }
    let(:valuator_group) { create(:valuator_group) }
    let(:valuator) { create(:valuator) }
    let(:administrator) { create(:administrator) }

    it "returns empty array if not valuators or administrator assigned" do
      expect(investment.admin_and_valuator_users_associated).to eq([])
    end

    it "returns all valuator and administrator users" do
      valuator_group.valuators << valuator
      investment.valuator_groups << valuator_group
      expect(investment.admin_and_valuator_users_associated).to eq([valuator])
      investment.administrator = administrator
      expect(investment.admin_and_valuator_users_associated).to eq([valuator, administrator])
    end

    it "returns uniq valuators or administrator users" do
      valuator_group.valuators << valuator
      investment.valuator_groups << valuator_group
      investment.valuators << valuator
      investment.administrator = administrator
      expect(investment.admin_and_valuator_users_associated).to eq([valuator, administrator])
    end
  end

  describe "milestone_tags" do
    context "without milestone_tags" do
      let(:investment) { create(:budget_investment) }

      it "do not have milestone_tags" do
        expect(investment.milestone_tag_list).to eq([])
        expect(investment.milestone_tags).to eq([])
      end

      it "add a new milestone_tag" do
        investment.milestone_tag_list = "tag1,tag2"

        expect(investment.milestone_tag_list).to eq(["tag1", "tag2"])
      end
    end

    context "with milestone_tags" do
      let(:investment) { create(:budget_investment, :with_milestone_tags) }

      it "has milestone_tags" do
        expect(investment.reload.milestone_tag_list.count).to eq(1)
      end
    end
  end
end
