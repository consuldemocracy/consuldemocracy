require "rails_helper"

describe Images::SuggestImagesComponent do
  let(:form_builder) { instance_double(ActionView::Helpers::FormBuilder, object: form_object) }
  let(:form_object) { build(:proposal) }

  describe "#render?" do
    context "when all LLM settings are present" do
      before do
        Setting["llm.provider"] = "OpenAI"
        Setting["llm.model"] = "gpt-4o"
        Setting["llm.use_ai_image_suggestions"] = true
      end

      it "returns true" do
        component = Images::SuggestImagesComponent.new(form_builder)
        expect(component.render?).to be true
      end
    end

    context "when provider is missing" do
      before do
        Setting["llm.provider"] = nil
        Setting["llm.model"] = "gpt-4o"
        Setting["llm.use_ai_image_suggestions"] = true
      end

      it "returns false" do
        component = Images::SuggestImagesComponent.new(form_builder)
        expect(component.render?).to be false
      end
    end

    context "when model is missing" do
      before do
        Setting["llm.provider"] = "OpenAI"
        Setting["llm.model"] = nil
        Setting["llm.use_ai_image_suggestions"] = true
      end

      it "returns false" do
        component = Images::SuggestImagesComponent.new(form_builder)
        expect(component.render?).to be false
      end
    end

    context "when use_ai_image_suggestions is missing" do
      before do
        Setting["llm.provider"] = "OpenAI"
        Setting["llm.model"] = "gpt-4o"
        Setting["llm.use_ai_image_suggestions"] = nil
      end

      it "returns false" do
        component = Images::SuggestImagesComponent.new(form_builder)
        expect(component.render?).to be false
      end
    end

    context "when all settings are blank" do
      before do
        Setting["llm.provider"] = nil
        Setting["llm.model"] = nil
        Setting["llm.use_ai_image_suggestions"] = nil
      end

      it "returns false" do
        component = Images::SuggestImagesComponent.new(form_builder)
        expect(component.render?).to be false
      end
    end
  end

  describe "#resource_type" do
    it "returns the class name of the form object" do
      component = Images::SuggestImagesComponent.new(form_builder)
      expect(component.send(:resource_type)).to eq("Proposal")
    end
  end

  describe "#resource_id" do
    context "when object is persisted" do
      let(:form_object) { create(:proposal) }

      it "returns the object id" do
        component = Images::SuggestImagesComponent.new(form_builder)
        expect(component.send(:resource_id)).to eq(form_object.id)
      end
    end

    context "when object is not persisted" do
      it "returns nil" do
        component = Images::SuggestImagesComponent.new(form_builder)
        expect(component.send(:resource_id)).to be(nil)
      end
    end
  end
end
