require "rails_helper"

describe SDG::ProcessEnabled do
  describe "#enabled?" do
    context "SDG feature and namespace are enabled" do
      before do
        Setting["feature.sdg"] = true
        %w[debates proposals polls budgets legislation].each do |process_name|
          Setting["sdg.process.#{process_name}"] = true
        end
      end

      it "returns true with relatable records" do
        SDG::Related::RELATABLE_TYPES.each do |relatable_type|
          process = SDG::ProcessEnabled.new(relatable_type.constantize.new)

          expect(process).to be_enabled
        end
      end

      it "returns true with relatable class names" do
        SDG::Related::RELATABLE_TYPES.each do |relatable_type|
          process = SDG::ProcessEnabled.new(relatable_type)

          expect(process).to be_enabled
        end
      end

      it "returns true with relatable controller paths" do
        process = SDG::ProcessEnabled.new("budgets/investments")

        expect(process).to be_enabled
      end

      it "returns false when record or name are not a relatable type" do
        expect(SDG::ProcessEnabled.new(build(:legislation_proposal))).not_to be_enabled
        expect(SDG::ProcessEnabled.new("Legislation::Proposal")).not_to be_enabled
        expect(SDG::ProcessEnabled.new("officing/booth")).not_to be_enabled
      end
    end

    context "SDG feature is disabled" do
      before do
        Setting["feature.sdg"] = false
        Setting["sdg.process.debates"] = true
      end

      it "returns false" do
        expect(SDG::ProcessEnabled.new(build(:debate))).not_to be_enabled
        expect(SDG::ProcessEnabled.new("Debate")).not_to be_enabled
        expect(SDG::ProcessEnabled.new("debates")).not_to be_enabled
      end
    end

    context "Some SDG processes are disabled" do
      before do
        Setting["feature.sdg"] = true
        Setting["sdg.process.debates"] = true
        Setting["sdg.process.proposals"] = false
      end

      it "returns false for disabled processes" do
        expect(SDG::ProcessEnabled.new(build(:proposal))).not_to be_enabled
        expect(SDG::ProcessEnabled.new("Proposal")).not_to be_enabled
        expect(SDG::ProcessEnabled.new("proposals")).not_to be_enabled
      end

      it "returns true for enabled processes" do
        expect(SDG::ProcessEnabled.new(build(:debate))).to be_enabled
        expect(SDG::ProcessEnabled.new("Debate")).to be_enabled
        expect(SDG::ProcessEnabled.new("debates")).to be_enabled
      end
    end
  end
end
