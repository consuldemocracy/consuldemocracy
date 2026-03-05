require "rails_helper"

describe Images::SuggestImagesComponent do
  let(:budget_investment) { build(:budget_investment) }
  let(:form) do
    ConsulFormBuilder.new(:budget_investment, budget_investment, ApplicationController.new.view_context, {})
  end
  let(:component) { Images::SuggestImagesComponent.new(form) }

  before do
    Setting["llm.provider"] = nil
    Setting["llm.model"] = nil
    Setting["llm.use_ai_image_suggestions"] = nil
  end

  describe "rendering" do
    context "when all LLM settings are present" do
      before do
        Setting["llm.provider"] = "OpenAI"
        Setting["llm.model"] = "gpt-4o"
        Setting["llm.use_ai_image_suggestions"] = true
      end

      it "renders the suggest images wrapper with data attributes and button" do
        render_inline component

        expect(page).to be_rendered
        expect(page).to have_css ".suggested-images-wrapper"
        expect(page).to have_css ".suggested-images-container"
        expect(page).to have_css "button.js-suggest-image"
        expect(page).to have_css ".suggested-images-wrapper[data-resource-type='Budget::Investment']"
        expect(page).to have_css ".suggested-images-wrapper[data-resource-id='']"
        expect(page).to have_content "Suggest an image with AI"
      end

      context "when budget_investment is persisted" do
        let(:budget_investment) { create(:budget_investment) }

        it "renders data-resource-id with the object id" do
          render_inline component

          expect(page).to have_css ".suggested-images-wrapper[data-resource-type='Budget::Investment'][data-resource-id='#{budget_investment.id}']"
        end
      end
    end

    context "when LLM settings are not configured" do
      it "does not render the component" do
        render_inline component

        expect(page).not_to be_rendered
      end
    end

    context "when provider is missing" do
      before do
        Setting["llm.provider"] = nil
        Setting["llm.model"] = "gpt-4o"
        Setting["llm.use_ai_image_suggestions"] = true
      end

      it "does not render the component" do
        render_inline component

        expect(page).not_to be_rendered
      end
    end

    context "when model is missing" do
      before do
        Setting["llm.provider"] = "OpenAI"
        Setting["llm.model"] = nil
        Setting["llm.use_ai_image_suggestions"] = true
      end

      it "does not render the component" do
        render_inline component

        expect(page).not_to be_rendered
      end
    end

    context "when use_ai_image_suggestions is missing" do
      before do
        Setting["llm.provider"] = "OpenAI"
        Setting["llm.model"] = "gpt-4o"
        Setting["llm.use_ai_image_suggestions"] = nil
      end

      it "does not render the component" do
        render_inline component

        expect(page).not_to be_rendered
      end
    end
  end
end
