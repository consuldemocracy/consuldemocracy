require "rails_helper"

describe SDGManagement::MenuComponent, type: :component do
  let(:component) { SDGManagement::MenuComponent.new }

  before do
    Setting["feature.sdg"] = true
    Setting["sdg.process.budgets"] = true
    Setting["sdg.process.debates"] = true
    Setting["sdg.process.legislation"] = true
    Setting["sdg.process.polls"] = true
    Setting["sdg.process.proposals"] = true
  end

  context "processes enabled" do
    it "generates links to all processes" do
      render_inline component

      expect(page).to have_link "Goals and Targets"
      expect(page).to have_link "SDG homepage"
      expect(page).to have_link "Participatory budgets"
      expect(page).to have_link "Debates"
      expect(page).to have_link "Collaborative legislation"
      expect(page).to have_link "Polls"
      expect(page).to have_link "Proposals"
    end
  end

  context "processes disabled" do
    before do
      Setting["process.budgets"] = false
      Setting["process.debates"] = false
      Setting["process.legislation"] = false
      Setting["process.polls"] = false
      Setting["process.proposals"] = false
    end

    it "does not generate links to any processes" do
      render_inline component

      expect(page).to have_css "a", count: 2
      expect(page).to have_link "Goals and Targets"
      expect(page).to have_link "SDG homepage"
    end
  end

  context "SDG processes disabled" do
    before do
      Setting["sdg.process.budgets"] = false
      Setting["sdg.process.debates"] = false
      Setting["sdg.process.legislation"] = false
      Setting["sdg.process.polls"] = false
      Setting["sdg.process.proposals"] = false
    end

    it "does not generate links to any processes" do
      render_inline component

      expect(page).to have_css "a", count: 2
      expect(page).to have_link "Goals and Targets"
      expect(page).to have_link "SDG homepage"
    end
  end

  context "one process disabled" do
    before { Setting["process.debates"] = false }

    it "generates links to the enabled processes" do
      render_inline component

      expect(page).to have_link "Goals and Targets"
      expect(page).to have_link "SDG homepage"
      expect(page).to have_link "Participatory budgets"
      expect(page).to have_link "Collaborative legislation"
      expect(page).to have_link "Polls"
      expect(page).to have_link "Proposals"

      expect(page).not_to have_link "Debates"
    end
  end

  context "one SDG process disabled" do
    before { Setting["sdg.process.legislation"] = false }

    it "generates links to the enabled processes" do
      render_inline component

      expect(page).to have_link "Goals and Targets"
      expect(page).to have_link "SDG homepage"
      expect(page).to have_link "Debates"
      expect(page).to have_link "Participatory budgets"
      expect(page).to have_link "Polls"
      expect(page).to have_link "Proposals"

      expect(page).not_to have_link "Collaborative legislation"
    end
  end
end
