require "rails_helper"

describe ClassificationSuggestions::PromptBuilder do
  def build(sdg_enabled: false, **attrs)
    described_class.new(
      title: "Green parks",
      summary: "More trees",
      description: "Plant trees downtown",
      locale: :en,
      max_tags: 4,
      max_sdgs: 3,
      sdg_enabled: sdg_enabled,
      **attrs
    )
  end

  describe "#system_instructions" do
    before do
      create(:tag, :category, name: "Health")
      create(:tag, :category, name: "Culture")
    end

    it "includes categories in alphabetical order, max_tags, and locale" do
      instructions = build.system_instructions
      categories = instructions[%r{<available_categories>\n(.*?)\n</available_categories>}m, 1]

      expect(categories).to eq("Culture\nHealth")
      expect(instructions).to include("<max_tags>4</max_tags>")
      expect(instructions).to include("<locale>en</locale>")
    end

    it "omits the SDG appendix when disabled" do
      instructions = build(sdg_enabled: false).system_instructions

      expect(instructions).not_to include("<available_sdgs>")
      expect(instructions).not_to include("sdg_instructions")
      expect(instructions).not_to include("<max_sdgs>")
    end

    it "appends SDG goals, targets, local targets, and max_sdgs when enabled" do
      local_target = create(:sdg_local_target, code: "1.1.1")
      target = local_target.target
      goal = local_target.goal

      instructions = build(sdg_enabled: true).system_instructions

      expect(instructions).to include("<max_sdgs>3</max_sdgs>")
      expect(instructions).to include("sdg_instructions")
      expect(instructions).to include("#{goal.code} | #{goal.title}")
      expect(instructions).to include("#{target.code} | #{target.title}")
      expect(instructions).to include("#{local_target.code} | #{local_target.title}")
    end

    describe "prompt caching: stable catalogues before per-request fields" do
      it "keeps available_categories ahead of locale and max_tags so the " \
         "category list stays in a reusable prompt-cache prefix" do
        instructions = build.system_instructions

        expect(instructions.index("</available_categories>")).to be <
                                                                 instructions.index("<locale>")
        expect(instructions.index("</available_categories>")).to be <
                                                                 instructions.index("<max_tags>")
      end

      it "keeps available_sdgs ahead of locale, max_tags, and max_sdgs so the " \
         "SDG list stays in a reusable prompt-cache prefix" do
        create(:sdg_local_target, code: "1.1.1")

        instructions = build(sdg_enabled: true).system_instructions

        expect(instructions.index("</available_sdgs>")).to be <
                                                           instructions.index("<locale>")
        expect(instructions.index("</available_sdgs>")).to be <
                                                           instructions.index("<max_tags>")
        expect(instructions.index("</available_sdgs>")).to be <
                                                           instructions.index("<max_sdgs>")
      end
    end
  end

  describe "#user_message" do
    it "includes truncated draft fields" do
      message = build(
        title: "T" * 100,
        summary: "S" * 250,
        description: "D" * 6100
      ).user_message

      expect(message).to include("<title>#{"T" * 80}</title>")
      expect(message).to include("<summary>#{"S" * 200}</summary>")
      expect(message).to include("<description>#{"D" * 6000}</description>")
      expect(message).not_to include("T" * 81)
    end

    it "renders blank draft fields as empty tags" do
      message = build(title: nil, summary: nil, description: nil).user_message

      expect(message).to include("<title></title>")
      expect(message).to include("<summary></summary>")
      expect(message).to include("<description></description>")
    end

    it "splits selected tags into categories and free-form tags and includes SDGs" do
      create(:tag, :category, name: "Culture")

      message = build(
        selected_tags: ["Culture", "bike lanes", "trees"],
        selected_sdgs: ["11", "13.1"]
      ).user_message

      expect(message).to match(
        %r{<selected_categories>\s*Culture\s*</selected_categories>}m
      )
      expect(message).to match(
        %r{<selected_tags>\s*bike lanes\ntrees\s*</selected_tags>}m
      )
      expect(message).to match(
        %r{<selected_sdgs>\s*11\n13\.1\s*</selected_sdgs>}m
      )
    end

    it "renders empty selected blocks when nothing is selected" do
      message = build.user_message

      expect(message).to match(%r{<selected_categories>\s*</selected_categories>}m)
      expect(message).to match(%r{<selected_tags>\s*</selected_tags>}m)
      expect(message).to match(%r{<selected_sdgs>\s*</selected_sdgs>}m)
    end

    it "dedupes and canonicalizes selected categories and free-form tags" do
      create(:tag, :category, name: "Culture")

      message = build(
        selected_tags: ["culture", "Culture", "parks", "Parks"],
        selected_sdgs: ["11", "13.1"]
      ).user_message

      expect(message).to match(
        %r{<selected_categories>\s*Culture\s*</selected_categories>}m
      )
      expect(message).to match(
        %r{<selected_tags>\s*parks\s*</selected_tags>}m
      )
      expect(message).to match(
        %r{<selected_sdgs>\s*11\n13\.1\s*</selected_sdgs>}m
      )
    end
  end
end
