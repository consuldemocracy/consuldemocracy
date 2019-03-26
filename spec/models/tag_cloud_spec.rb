require "rails_helper"

describe TagCloud do

  describe "#tags" do

    it "returns proposal tags" do
      create(:proposal, tag_list: "participation")
      create(:debate,   tag_list: "world hunger")

      tag_cloud = described_class.new(Proposal)

      expect(tag_names(tag_cloud)).to contain_exactly("participation")
    end

    it "returns debate tags" do
      create(:proposal, tag_list: "participation")
      create(:debate,   tag_list: "world hunger")

      tag_cloud = described_class.new(Debate)

      expect(tag_names(tag_cloud)).to contain_exactly("world hunger")
    end

    it "returns budget investment tags" do
      create(:budget_investment, tag_list: "participation")
      create(:debate, tag_list: "world hunger")

      tag_cloud = described_class.new(Budget::Investment)

      expect(tag_names(tag_cloud)).to contain_exactly("participation")
    end

    it "returns tags from last week" do
      create(:proposal, tag_list: "participation", created_at: 1.day.ago)
      create(:proposal, tag_list: "corruption",    created_at: 2.weeks.ago)

      tag_cloud = described_class.new(Proposal)

      expect(tag_names(tag_cloud)).to contain_exactly("participation")
    end

    it "does not return category tags" do
      create(:tag, :category, name: "Education")
      create(:tag, :category, name: "Participation")

      create(:proposal, tag_list: "education, parks")
      create(:proposal, tag_list: "participation, water")

      tag_cloud = described_class.new(Proposal)

      expect(tag_names(tag_cloud)).to contain_exactly("parks", "water")
    end

    it "does not return geozone names" do
      create(:geozone, name: "California")
      create(:geozone, name: "New York")

      create(:proposal, tag_list: "parks, California")
      create(:proposal, tag_list: "water, New York")

      tag_cloud = described_class.new(Proposal)

      expect(tag_names(tag_cloud)).to contain_exactly("parks", "water")
    end

    it "returns tags scoped by category" do
      create(:tag, :category, name: "Education")
      create(:tag, :category, name: "Participation")

      create(:proposal, tag_list: "education, parks")
      create(:proposal, tag_list: "participation, water")

      tag_cloud = described_class.new(Proposal, "Education")

      expect(tag_names(tag_cloud)).to contain_exactly("parks")
    end

    it "returns tags scoped by geozone" do
      create(:geozone, name: "California")
      create(:geozone, name: "New York")

      create(:proposal, tag_list: "parks, California")
      create(:proposal, tag_list: "water, New York")

      tag_cloud = described_class.new(Proposal, "California")

      expect(tag_names(tag_cloud)).to contain_exactly("parks")
    end

    xit "returns tags scoped by category for debates"
    xit "returns tags scoped by geozone for debates"

    it "orders tags by count" do
      3.times { create(:proposal, tag_list: "participation") }
      create(:proposal, tag_list: "corruption")

      tag_cloud = described_class.new(Proposal)

      expect(tag_names(tag_cloud).first).to eq "participation"
      expect(tag_names(tag_cloud).second).to eq "corruption"
    end

    it "orders tags by count and then by name" do
      3.times { create(:proposal, tag_list: "participation") }
      3.times { create(:proposal, tag_list: "health") }
      create(:proposal, tag_list: "corruption")

      tag_cloud = described_class.new(Proposal)

      expect(tag_names(tag_cloud).first).to  eq "health"
      expect(tag_names(tag_cloud).second).to eq "participation"
      expect(tag_names(tag_cloud).third).to  eq "corruption"
    end

    it "returns a maximum of 10 tags" do
      12.times { |i| create(:proposal, tag_list: "Tag #{i}") }

      tag_cloud = described_class.new(Proposal)

      expect(tag_names(tag_cloud).count).to eq(10)
    end
  end

end