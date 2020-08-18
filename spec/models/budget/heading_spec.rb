require "rails_helper"

describe Budget::Heading do
  let(:budget) { create(:budget) }
  let(:group) { create(:budget_group, budget: budget) }

  it_behaves_like "sluggable", updatable_slug_trait: :drafting_budget
  it_behaves_like "globalizable", :budget_heading

  describe "OSM_DISTRICT_LEVEL_ZOOM constant" do
    it "is defined" do
      expect(Budget::Heading::OSM_DISTRICT_LEVEL_ZOOM).to be 12
    end
  end

  describe "name" do
    let(:heading) { create(:budget_heading, group: group) }

    before do
      heading.update(name_en: "object name")
    end

    it "can be repeatead in other budgets" do
      new_budget = create(:budget)
      new_group = create(:budget_group, budget: new_budget)

      expect(build(:budget_heading, group: new_group, name_en: "object name")).to be_valid
    end

    it "must be unique among all budget's groups" do
      new_group = create(:budget_group, budget: budget)

      expect(build(:budget_heading, group: new_group, name_en: "object name")).not_to be_valid
    end

    it "must be unique among all it's group" do
      expect(build(:budget_heading, group: group, name_en: "object name")).not_to be_valid
    end

    it "can be repeated for the same heading and a different locale" do
      heading.update!(name_fr: "object name")

      expect(heading.translations.last).to be_valid
    end

    it "must not be repeated for a different heading in any locale" do
      heading.update!(name_en: "English", name_es: "Español")

      expect(build(:budget_heading, group: group, name_en: "English")).not_to be_valid
      expect(build(:budget_heading, group: group, name_en: "Español")).not_to be_valid
    end
  end

  describe "Save population" do
    it "Allows population == nil" do
      expect(create(:budget_heading, group: group, name: "Population is nil", population: nil)).to be_valid
    end

    it "Doesn't allow population <= 0" do
      heading = create(:budget_heading, group: group, name: "Population is > 0")

      heading.population = 0
      expect(heading).not_to be_valid

      heading.population = -10
      expect(heading).not_to be_valid

      heading.population = 10
      expect(heading).to be_valid
    end
  end

  describe "save latitude" do
    it "Doesn't allow latitude < -90" do
      heading = create(:budget_heading, group: group, name: "Latitude is < -90")

      heading.latitude = "-90.127491"
      expect(heading).not_to be_valid

      heading.latitude = "-91.723491"
      expect(heading).not_to be_valid

      heading.latitude = "-108.127412"
      expect(heading).not_to be_valid

      heading.latitude = "-1100.888491"
      expect(heading).not_to be_valid
    end

    it "Doesn't allow latitude > 90" do
      heading = create(:budget_heading, group: group, name: "Latitude is > 90")

      heading.latitude = "90.127491"
      expect(heading).not_to be_valid

      heading.latitude = "97.723491"
      expect(heading).not_to be_valid

      heading.latitude = "119.127412"
      expect(heading).not_to be_valid

      heading.latitude = "1200.888491"
      expect(heading).not_to be_valid

      heading.latitude = "+128.888491"
      expect(heading).not_to be_valid

      heading.latitude = "+255.888491"
      expect(heading).not_to be_valid
    end

    it "Doesn't allow latitude length > 22" do
      heading = create(:budget_heading, group: group, name: "Latitude length is  > 22")

      heading.latitude = "10.12749112312418238128213"
      expect(heading).not_to be_valid

      heading.latitude = "7.7234941211121231231241"
      expect(heading).not_to be_valid

      heading.latitude = "9.1274124111241248688995"
      expect(heading).not_to be_valid

      heading.latitude = "+12.8884911231238684445311"
      expect(heading).not_to be_valid
    end

    it "Allows latitude inside [-90,90] interval" do
      heading = create(:budget_heading, group: group, name: "Latitude is inside [-90,90] interval")

      heading.latitude = "90"
      expect(heading).to be_valid

      heading.latitude = "-90"
      expect(heading).to be_valid

      heading.latitude = "-90.000"
      expect(heading).to be_valid

      heading.latitude = "-90.00000"
      expect(heading).to be_valid

      heading.latitude = "90.000"
      expect(heading).to be_valid

      heading.latitude = "90.00000"
      expect(heading).to be_valid

      heading.latitude = "-80.123451"
      expect(heading).to be_valid

      heading.latitude = "+65.888491"
      expect(heading).to be_valid

      heading.latitude = "80.144812"
      expect(heading).to be_valid

      heading.latitude = "17.417412"
      expect(heading).to be_valid

      heading.latitude = "-21.000054"
      expect(heading).to be_valid

      heading.latitude = "+80.888491"
      expect(heading).to be_valid
    end
  end

  describe "save longitude" do
    it "Doesn't allow longitude < -180" do
      heading = create(:budget_heading, group: group, name: "Longitude is < -180")

      heading.longitude = "-180.127491"
      expect(heading).not_to be_valid

      heading.longitude = "-181.723491"
      expect(heading).not_to be_valid

      heading.longitude = "-188.127412"
      expect(heading).not_to be_valid

      heading.longitude = "-1100.888491"
      expect(heading).not_to be_valid
    end

    it "Doesn't allow longitude > 180" do
      heading = create(:budget_heading, group: group, name: "Longitude is > 180")

      heading.longitude = "190.127491"
      expect(heading).not_to be_valid

      heading.longitude = "197.723491"
      expect(heading).not_to be_valid

      heading.longitude = "+207.723491"
      expect(heading).not_to be_valid

      heading.longitude = "300.723491"
      expect(heading).not_to be_valid

      heading.longitude = "189.127412"
      expect(heading).not_to be_valid

      heading.longitude = "1200.888491"
      expect(heading).not_to be_valid
    end

    it "Doesn't allow longitude length > 23" do
      heading = create(:budget_heading, group: group, name: "Longitude length is > 23")

      heading.longitude = "50.1274911123124112312418238128213"
      expect(heading).not_to be_valid

      heading.longitude = "53.73412349178811231241"
      expect(heading).not_to be_valid

      heading.longitude = "+20.1274124124124123121435"
      expect(heading).not_to be_valid

      heading.longitude = "10.88849112312312311232123311"
      expect(heading).not_to be_valid
    end

    it "Allows longitude inside [-180,180] interval" do
      heading = create(:budget_heading, group: group,
                       name: "Longitude is inside [-180,180] interval")

      heading.longitude = "180"
      expect(heading).to be_valid

      heading.longitude = "-180"
      expect(heading).to be_valid

      heading.longitude = "-180.000"
      expect(heading).to be_valid

      heading.longitude = "-180.00000"
      expect(heading).to be_valid

      heading.longitude = "180.000"
      expect(heading).to be_valid

      heading.longitude = "180.00000"
      expect(heading).to be_valid

      heading.longitude = "+75.00000"
      expect(heading).to be_valid

      heading.longitude = "+15.023321"
      expect(heading).to be_valid

      heading.longitude = "-80.123451"
      expect(heading).to be_valid

      heading.longitude = "80.144812"
      expect(heading).to be_valid

      heading.longitude = "17.417412"
      expect(heading).to be_valid

      heading.longitude = "-21.000054"
      expect(heading).to be_valid
    end
  end

  describe "heading" do
    it "can be deleted if no budget's investments associated" do
      heading1 = create(:budget_heading, group: group, name: "name")
      heading2 = create(:budget_heading, group: group, name: "name 2")

      create(:budget_investment, heading: heading1)

      expect(heading1.can_be_deleted?).to eq false
      expect(heading2.can_be_deleted?).to eq true
    end
  end

  describe ".sort_by_name" do
    it "returns headings sorted by DESC group name first and then ASC heading name" do
      last_group  = create(:budget_group, name: "Group A")
      first_group = create(:budget_group, name: "Group B")

      heading4 = create(:budget_heading, group: last_group, name: "Name B")
      heading3 = create(:budget_heading, group: last_group, name: "Name A")
      heading2 = create(:budget_heading, group: first_group, name: "Name D")
      heading1 = create(:budget_heading, group: first_group, name: "Name C")

      sorted_headings = [heading1, heading2, heading3, heading4]
      expect(Budget::Heading.sort_by_name).to eq sorted_headings
    end

    it "only sort headings using the group name (DESC) in the current locale" do
      last_group  = create(:budget_group, name_en: "CCC", name_es: "BBB")
      first_group = create(:budget_group, name_en: "DDD", name_es: "AAA")

      last_heading = create(:budget_heading, group: last_group, name: "Name")
      first_heading = create(:budget_heading, group: first_group, name: "Name")

      expect(Budget::Heading.sort_by_name).to eq [first_heading, last_heading]
    end
  end

  describe "scope allow_custom_content" do
    it "returns headings with allow_custom_content order by name" do
      last_heading     = create(:budget_heading, allow_custom_content: true, name: "Name B")
      first_heading    = create(:budget_heading, allow_custom_content: true, name: "Name A")

      expect(Budget::Heading.allow_custom_content).to eq [first_heading, last_heading]
    end

    it "does not return headings which don't allow custom content" do
      create(:budget_heading, name: "Name A")

      expect(Budget::Heading.allow_custom_content).to be_empty
    end

    it "returns headings with multiple translations only once" do
      translated_heading = create(:budget_heading,
                                  allow_custom_content: true,
                                  name_en: "English",
                                  name_es: "Spanish")

      expect(Budget::Heading.allow_custom_content).to eq [translated_heading]
    end
  end

  describe "#max_ballot_lines" do
    it "must be at least 1" do
      expect(build(:budget_heading, max_ballot_lines: 1)).to be_valid
      expect(build(:budget_heading, max_ballot_lines: 10)).to be_valid
      expect(build(:budget_heading, max_ballot_lines: -1)).not_to be_valid
      expect(build(:budget_heading, max_ballot_lines: 0)).not_to be_valid
    end
  end
end
