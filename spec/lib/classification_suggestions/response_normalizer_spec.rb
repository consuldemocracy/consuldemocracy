require "rails_helper"

describe ClassificationSuggestions::ResponseNormalizer do
  def normalize(parsed, selected_tags: [], selected_sdgs: [], sdg_enabled: true)
    described_class.new(
      parsed,
      selected_tags: selected_tags,
      selected_sdgs: selected_sdgs,
      sdg_enabled: sdg_enabled
    ).call
  end

  it "returns empty suggestions when the response is not a hash" do
    expect(normalize("not a hash")).to eq(categories: [], tags: [], sdgs: [])
  end

  describe "categories" do
    it "drops categories that do not exist" do
      create(:tag, :category, name: "Culture")

      result = normalize({ "categories" => ["Culture", "Unknown"] })

      expect(result[:categories]).to eq(["Culture"])
    end

    it "promotes tags that match category names" do
      create(:tag, :category, name: "Health")

      result = normalize({ "tags" => ["health", "parks"] })

      expect(result[:categories]).to eq(["Health"])
      expect(result[:tags]).to eq(["parks"])
    end

    it "does not repeat a category that appears in both categories and tags" do
      create(:tag, :category, name: "Culture")

      result = normalize({ "categories" => ["Culture"], "tags" => ["culture", "parks"] })

      expect(result[:categories]).to eq(["Culture"])
      expect(result[:tags]).to eq(["parks"])
    end

    it "skips already selected categories case-insensitively" do
      create(:tag, :category, name: "Culture")

      result = normalize({ "categories" => ["Culture"] }, selected_tags: ["culture"])

      expect(result[:categories]).to eq([])
    end

    it "suggests at most two categories" do
      create(:tag, :category, name: "Culture")
      create(:tag, :category, name: "Health")
      create(:tag, :category, name: "Sports")

      result = normalize({ "categories" => ["Culture", "Health", "Sports"] })

      expect(result[:categories]).to eq(["Culture", "Health"])
    end
  end

  describe "tags" do
    it "keeps free-form tags" do
      result = normalize({ "tags" => ["parks", "trees"] })

      expect(result[:tags]).to eq(["parks", "trees"])
    end

    it "sanitizes tags and collapses case duplicates" do
      result = normalize({ "tags" => ["hello?world", "HelloWorld", "Parks"] })

      expect(result[:tags]).to eq(["helloworld", "Parks"])
    end

    it "skips already selected tags case-insensitively" do
      result = normalize({ "tags" => ["Parks", "trees"] }, selected_tags: ["parks"])

      expect(result[:tags]).to eq(["trees"])
    end

    it "fills only the tag list slots left after categories" do
      create(:tag, :category, name: "Culture")

      result = normalize(
        { "categories" => ["Culture"], "tags" => ["one", "two", "three"] },
        selected_tags: ["a", "b", "c", "d"]
      )

      expect(result[:categories]).to eq(["Culture"])
      expect(result[:tags]).to eq(["one"])
    end

    it "returns no categories or tags when the tag list is full" do
      create(:tag, :category, name: "Culture")

      result = normalize(
        { "categories" => ["Culture"], "tags" => ["parks"] },
        selected_tags: ["a", "b", "c", "d", "e", "f"]
      )

      expect(result[:categories]).to eq([])
      expect(result[:tags]).to eq([])
    end
  end

  describe "SDGs" do
    it "keeps known codes with their reasons" do
      result = normalize({ "sdgs" => [{ "code" => "1.1", "reason" => "About poverty" }] })

      expect(result[:sdgs]).to eq([{ "code" => "1.1", "reason" => "About poverty" }])
    end

    it "drops unknown codes" do
      result = normalize({ "sdgs" => [{ "code" => "99", "reason" => "Not a goal" }] })

      expect(result[:sdgs]).to eq([])
    end

    it "skips already selected codes" do
      result = normalize(
        { "sdgs" => [{ "code" => "3", "reason" => "Health" }, { "code" => "4", "reason" => "Education" }] },
        selected_sdgs: ["3"]
      )

      expect(result[:sdgs]).to eq([{ "code" => "4", "reason" => "Education" }])
    end

    it "ignores non-hash entries and duplicate codes" do
      result = normalize(
        {
          "sdgs" => [
            "11",
            { "code" => "3", "reason" => "Health" },
            { "code" => "3", "reason" => "Duplicate" }
          ]
        }
      )

      expect(result[:sdgs]).to eq([{ "code" => "3", "reason" => "Health" }])
    end

    it "suggests at most the remaining SDG slots" do
      result = normalize(
        { "sdgs" => [{ "code" => "6", "reason" => "Water" }, { "code" => "7", "reason" => "Energy" }] },
        selected_sdgs: ["1", "2", "3", "4", "5"]
      )

      expect(result[:sdgs]).to eq([{ "code" => "6", "reason" => "Water" }])
    end

    it "truncates long reasons" do
      result = normalize({ "sdgs" => [{ "code" => "3", "reason" => "x" * 400 }] })

      expect(result[:sdgs].first["reason"].length).to eq(described_class::REASON_MAX_LENGTH)
    end

    it "returns nothing when SDGs are disabled" do
      result = normalize({ "sdgs" => [{ "code" => "3", "reason" => "Health" }] }, sdg_enabled: false)

      expect(result[:sdgs]).to eq([])
    end
  end
end
