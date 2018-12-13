require 'rails_helper'

describe Budget::Heading do

  let(:budget) { create(:budget) }
  let(:group) { create(:budget_group, budget: budget) }

  it_behaves_like "sluggable", updatable_slug_trait: :drafting_budget

  describe "::OSM_DISTRICT_LEVEL_ZOOM" do
    it "should be defined" do
      expect(Budget::Heading::OSM_DISTRICT_LEVEL_ZOOM).to be 12
    end
  end

  describe "name" do
    before do
      create(:budget_heading, group: group, name: 'object name')
    end

    it "can be repeatead in other budget's groups" do
      expect(build(:budget_heading, group: create(:budget_group), name: 'object name')).to be_valid
    end

    it "must be unique among all budget's groups" do
      expect(build(:budget_heading, group: create(:budget_group, budget: budget), name: 'object name')).not_to be_valid
    end

    it "must be unique among all it's group" do
      expect(build(:budget_heading, group: group, name: 'object name')).not_to be_valid
    end
  end

  describe "Save population" do
    it "Allows population == nil" do
      expect(create(:budget_heading, group: group, name: 'Population is nil', population: nil)).to be_valid
    end

    it "Doesn't allow population <= 0" do
      heading = create(:budget_heading, group: group, name: 'Population is > 0')

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
      heading = create(:budget_heading, group: group, name: 'Latitude is < -90')

      heading.latitude = '-90.127491'
      expect(heading).not_to be_valid

      heading.latitude = '-91.723491'
      expect(heading).not_to be_valid

      heading.latitude = '-108.127412'
      expect(heading).not_to be_valid

      heading.latitude = '-1100.888491'
      expect(heading).not_to be_valid
    end

    it "Doesn't allow latitude > 90" do
      heading = create(:budget_heading, group: group, name: 'Latitude is > 90')

      heading.latitude = '90.127491'
      expect(heading).not_to be_valid

      heading.latitude = '97.723491'
      expect(heading).not_to be_valid

      heading.latitude = '119.127412'
      expect(heading).not_to be_valid

      heading.latitude = '1200.888491'
      expect(heading).not_to be_valid

      heading.latitude = '+128.888491'
      expect(heading).not_to be_valid

      heading.latitude = '+255.888491'
      expect(heading).not_to be_valid
    end

    it "Doesn't allow latitude length > 22" do
      heading = create(:budget_heading, group: group, name: 'Latitude length is  > 22')

      heading.latitude = '10.12749112312418238128213'
      expect(heading).not_to be_valid

      heading.latitude = '7.7234941211121231231241'
      expect(heading).not_to be_valid

      heading.latitude = '9.1274124111241248688995'
      expect(heading).not_to be_valid

      heading.latitude = '+12.8884911231238684445311'
      expect(heading).not_to be_valid
    end

    it "Allows latitude inside [-90,90] interval" do
      heading = create(:budget_heading, group: group, name: 'Latitude is inside [-90,90] interval')

      heading.latitude = '90'
      expect(heading).to be_valid

      heading.latitude = '-90'
      expect(heading).to be_valid

      heading.latitude = '-90.000'
      expect(heading).to be_valid

      heading.latitude = '-90.00000'
      expect(heading).to be_valid

      heading.latitude = '90.000'
      expect(heading).to be_valid

      heading.latitude = '90.00000'
      expect(heading).to be_valid

      heading.latitude = '-80.123451'
      expect(heading).to be_valid

      heading.latitude = '+65.888491'
      expect(heading).to be_valid

      heading.latitude = '80.144812'
      expect(heading).to be_valid

      heading.latitude = '17.417412'
      expect(heading).to be_valid

      heading.latitude = '-21.000054'
      expect(heading).to be_valid

      heading.latitude = '+80.888491'
      expect(heading).to be_valid
    end
  end


  describe "save longitude" do

    it "Doesn't allow longitude < -180" do
      heading = create(:budget_heading, group: group, name: 'Longitude is < -180')

      heading.longitude = '-180.127491'
      expect(heading).not_to be_valid

      heading.longitude = '-181.723491'
      expect(heading).not_to be_valid

      heading.longitude = '-188.127412'
      expect(heading).not_to be_valid

      heading.longitude = '-1100.888491'
      expect(heading).not_to be_valid
    end

    it "Doesn't allow longitude > 180" do
      heading = create(:budget_heading, group: group, name: 'Longitude is > 180')

      heading.longitude = '190.127491'
      expect(heading).not_to be_valid

      heading.longitude = '197.723491'
      expect(heading).not_to be_valid

      heading.longitude = '+207.723491'
      expect(heading).not_to be_valid

      heading.longitude = '300.723491'
      expect(heading).not_to be_valid

      heading.longitude = '189.127412'
      expect(heading).not_to be_valid

      heading.longitude = '1200.888491'
      expect(heading).not_to be_valid
    end

    it "Doesn't allow longitude length > 23" do
      heading = create(:budget_heading, group: group, name: 'Longitude length is > 23')

      heading.longitude = '50.1274911123124112312418238128213'
      expect(heading).not_to be_valid

      heading.longitude = '53.73412349178811231241'
      expect(heading).not_to be_valid

      heading.longitude = '+20.1274124124124123121435'
      expect(heading).not_to be_valid

      heading.longitude = '10.88849112312312311232123311'
      expect(heading).not_to be_valid
    end

    it "Allows longitude inside [-180,180] interval" do
      heading = create(:budget_heading, group: group, name: 'Longitude is inside [-180,180] interval')

      heading.longitude = '180'
      expect(heading).to be_valid

      heading.longitude = '-180'
      expect(heading).to be_valid

      heading.longitude = '-180.000'
      expect(heading).to be_valid

      heading.longitude = '-180.00000'
      expect(heading).to be_valid

      heading.longitude = '180.000'
      expect(heading).to be_valid

      heading.longitude = '180.00000'
      expect(heading).to be_valid

      heading.longitude = '+75.00000'
      expect(heading).to be_valid

      heading.longitude = '+15.023321'
      expect(heading).to be_valid

      heading.longitude = '-80.123451'
      expect(heading).to be_valid

      heading.longitude = '80.144812'
      expect(heading).to be_valid

      heading.longitude = '17.417412'
      expect(heading).to be_valid

      heading.longitude = '-21.000054'
      expect(heading).to be_valid
    end
  end


  describe "heading" do
    it "can be deleted if no budget's investments associated" do
      heading1 = create(:budget_heading, group: group, name: 'name')
      heading2 = create(:budget_heading, group: group, name: 'name 2')

      create(:budget_investment, heading: heading1)

      expect(heading1.can_be_deleted?).to eq false
      expect(heading2.can_be_deleted?).to eq true
    end
  end

end
