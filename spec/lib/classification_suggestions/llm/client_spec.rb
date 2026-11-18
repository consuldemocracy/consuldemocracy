require "rails_helper"

describe ClassificationSuggestions::Llm::Client do
  let(:chat) { double("chat") }
  let(:model_info) { double("model", supports?: false) }
  let(:llm_reply) do
    {
      "categories" => ["Culture"],
      "tags" => ["parks"],
      "sdgs" => [{ "code" => "11", "reason" => "Urban greening" }]
    }
  end

  before do
    Setting["llm.provider"] = "OpenAI"
    Setting["llm.model"] = "gpt-4o"
    Setting["llm.use_ai_classification_suggestions"] = true
    Setting["feature.sdg"] = true
    Setting["sdg.process.proposals"] = true

    create(:tag, :category, name: "Culture")

    allow(Llm::Config).to receive(:context).and_return(double(config: RubyLLM::Configuration.new))
    allow(RubyLLM::Context).to receive(:new).and_return(double(chat: chat))
    allow(RubyLLM.models).to receive(:find).and_return(model_info)
    allow(chat).to receive(:with_instructions).and_return(chat)
  end

  def suggest(**args)
    described_class.call(title: "More green spaces", description: "Parks and trees in the centre.", **args)
  end

  def stub_llm_reply(payload)
    allow(chat).to receive(:ask).and_return(double(content: payload))
  end

  def stub_structured_output_support
    allow(model_info).to receive(:supports?).with(:structured_output).and_return(true)
    allow(chat).to receive(:with_schema).and_return(chat)
  end

  describe "suggestions" do
    it "returns normalized suggestions from a plain JSON reply" do
      stub_llm_reply(llm_reply.to_json)

      result = suggest

      expect(result.as_json).to eq(
        categories: ["Culture"],
        tags: ["parks"],
        sdgs: [{ "code" => "11", "reason" => "Urban greening" }],
        errors: []
      )
      expect(chat).to have_received(:with_instructions).with(a_string_including("<locale>"))
      expect(chat).to have_received(:ask).once
    end

    it "requests structured output when the model supports it" do
      stub_structured_output_support
      stub_llm_reply(llm_reply)

      result = suggest

      expect(result.categories).to eq(["Culture"])
      expect(chat).to have_received(:with_schema) do |schema|
        properties = schema[:properties] || schema["properties"]

        expect(schema).to be_a(Hash)
        expect(schema).not_to have_key(:strict)
        expect(schema).not_to have_key("strict")
        expect(schema[:type] || schema["type"]).to eq("object")
        expect(properties.keys.map(&:to_s)).to include("sdgs")
      end
    end

    it "uses the schema without SDGs when the SDG process is disabled" do
      Setting["sdg.process.proposals"] = false
      stub_structured_output_support
      stub_llm_reply(llm_reply.except("sdgs"))

      result = suggest

      expect(result.sdgs).to eq([])
      expect(chat).to have_received(:with_schema) do |schema|
        properties = schema[:properties] || schema["properties"]

        expect(schema).to be_a(Hash)
        expect(schema).not_to have_key(:strict)
        expect(schema).not_to have_key("strict")
        expect(properties.keys.map(&:to_s)).not_to include("sdgs")
      end
    end

    it "does not suggest tags or SDGs that are already selected" do
      stub_llm_reply(
        {
          "categories" => ["Culture"],
          "tags" => ["parks", "trees"],
          "sdgs" => [{ "code" => "11", "reason" => "Cities" }, { "code" => "3", "reason" => "Health" }]
        }.to_json
      )

      result = suggest(selected_tags: ["Culture", "parks"], selected_sdgs: ["11"])

      expect(result.categories).to eq([])
      expect(result.tags).to eq(["trees"])
      expect(result.sdgs).to eq([{ "code" => "3", "reason" => "Health" }])
    end
  end

  describe "skipping the LLM" do
    it "returns an error when the draft is blank" do
      result = suggest(title: "", description: "", summary: "")

      expect(result.as_json).to eq(
        categories: [], tags: [], sdgs: [],
        errors: ["Please add a title, summary or description before requesting suggestions."]
      )
      expect(RubyLLM::Context).not_to have_received(:new)
    end

    it "returns empty lists when the tag list is full and SDGs are disabled" do
      Setting["feature.sdg"] = false

      result = suggest(selected_tags: %w[a b c d e f])

      expect(result.as_json).to eq(categories: [], tags: [], sdgs: [], errors: [])
      expect(RubyLLM::Context).not_to have_received(:new)
    end

    it "returns an error when classification suggestions are disabled" do
      Setting["llm.use_ai_classification_suggestions"] = false

      result = suggest

      expect(result.as_json).to eq(
        categories: [], tags: [], sdgs: [],
        errors: ["LLM is not properly configured. Please contact an administrator."]
      )
      expect(RubyLLM::Context).not_to have_received(:new)
    end

    it "returns an error when the LLM is not configured" do
      Setting["llm.provider"] = nil
      Setting["llm.model"] = nil

      result = suggest

      expect(result.as_json).to eq(
        categories: [], tags: [], sdgs: [],
        errors: ["LLM is not properly configured. Please contact an administrator."]
      )
      expect(RubyLLM::Context).not_to have_received(:new)
    end
  end

  describe "errors" do
    it "returns a generic error when the LLM raises" do
      allow(chat).to receive(:ask).and_raise(RubyLLM::Error, "boom")

      result = suggest

      expect(result.as_json).to eq(
        categories: [], tags: [], sdgs: [],
        errors: ["Something went wrong generating suggestions. Please try again."]
      )
    end

    it "returns a generic error when the reply is not JSON" do
      stub_llm_reply("not json")

      result = suggest

      expect(result.as_json).to eq(
        categories: [], tags: [], sdgs: [],
        errors: ["Something went wrong generating suggestions. Please try again."]
      )
    end
  end
end
