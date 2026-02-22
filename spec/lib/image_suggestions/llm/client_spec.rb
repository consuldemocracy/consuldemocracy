require "rails_helper"

describe ImageSuggestions::Llm::Client do
  let(:title) { "Test Proposal" }
  let(:description) { "Test description" }
  let(:chat) { instance_double(RubyLLM::Chat) }
  let(:context) { instance_double(RubyLLM::Context, chat: chat) }
  let(:prompt_template) { "Generate a search query for: %{title} - %{description}" }
  let(:search_query) { "test proposal image" }
  let(:pexels_results) { instance_double(::Pexels::PhotoSet, photos: []) }

  before do
    Setting["llm.provider"] = "OpenAI"
    Setting["llm.model"] = "gpt-4o"
    Setting["llm.use_ai_image_suggestions"] = true
    allow(Llm::Config).to receive(:context).and_return(context)
    allow(YAML).to receive(:load_file).and_return({ "image_suggestion_prompt" => prompt_template })
    allow(chat).to receive(:ask).and_return(double(content: search_query))
    allow(ImageSuggestions::Pexels).to receive(:search).and_return(pexels_results)
  end

  describe ".call" do
    it "creates a new instance and calls it with title and description" do
      expect(ImageSuggestions::Llm::Client).to receive(:new).with(
        title: title,
        description: description
      ).and_call_original
      ImageSuggestions::Llm::Client.call(title: title, description: description)
    end
  end

  describe "#call" do
    let(:client) { ImageSuggestions::Llm::Client.new(title: title, description: description) }

    it "generates a search query using LLM" do
      expect(chat).to receive(:ask).with(
        "Generate a search query for: Test Proposal - Test description"
      ).and_return(double(content: search_query))

      client.call
    end

    it "searches Pexels with the generated query" do
      expect(ImageSuggestions::Pexels).to receive(:search).with(
        search_query,
        per_page: 4
      ).and_return(pexels_results)

      result = client.call
      expect(result.results).to eq(pexels_results)
    end

    it "returns a Response object with results" do
      result = client.call
      expect(result).to be_a(ImageSuggestions::Llm::Client::Response)
      expect(result.results).to eq(pexels_results)
      expect(result.errors).to be_empty
    end

    context "when title and description are blank" do
      let(:title) { "" }
      let(:description) { "" }
      let(:client) { ImageSuggestions::Llm::Client.new(title: title, description: description) }

      it "adds error and returns early" do
        result = client.call
        expect(result.errors).to include(I18n.t("images.errors.messages.title_and_description_required"))
        expect(result.results).to be_empty
      end

      it "does not call LLM or Pexels" do
        expect(chat).not_to receive(:ask)
        expect(ImageSuggestions::Pexels).not_to receive(:search)
        client.call
      end
    end

    context "when only description is present" do
      let(:title) { "" }
      let(:client) { ImageSuggestions::Llm::Client.new(title: title, description: description) }

      it "uses empty string for title in prompt" do
        expect(chat).to receive(:ask).with(
          "Generate a search query for:  - Test description"
        ).and_return(double(content: search_query))

        client.call
      end
    end

    context "when Pexels::APIError is raised" do
      before do
        allow(ImageSuggestions::Pexels).to receive(:search)
          .and_raise(::Pexels::APIError.new("API error"))
      end

      it "catches error and adds to response errors" do
        result = client.call
        expect(result.errors).to be_present
        expect(result.errors).to include("API error")
      end
    end

    context "when RubyLLM::Error is raised" do
      before do
        llm_error = RubyLLM::Error.new
        allow(llm_error).to receive(:message).and_return("LLM error")
        allow(chat).to receive(:ask).and_raise(llm_error)
      end

      it "catches error and adds to response errors" do
        result = client.call
        expect(result.errors).to include("LLM error")
      end
    end

    context "when LLM is not configured" do
      before do
        Setting["llm.provider"] = nil
        Setting["llm.model"] = nil
        Setting["llm.use_ai_image_suggestions"] = false
      end

      it "adds error to response and returns early" do
        result = client.call
        expect(result.errors).to include(I18n.t("images.errors.messages.llm_not_configured"))
        expect(result.results).to be_empty
      end
    end
  end

  describe "#generate_search_query" do
    let(:client) { ImageSuggestions::Llm::Client.new(title: title, description: description) }

    it "interpolates prompt with title and description" do
      query = client.send(:generate_search_query)
      expect(query).to eq(search_query)
    end

    it "strips whitespace from LLM response" do
      allow(chat).to receive(:ask).and_return(double(content: "  search query  "))
      query = client.send(:generate_search_query)
      expect(query).to eq("search query")
    end
  end

  describe "#validate_llm_settings!" do
    let(:client) { ImageSuggestions::Llm::Client.new(title: title, description: description) }

    context "when provider is missing" do
      before { Setting["llm.provider"] = nil }

      it "adds error to response" do
        client.send(:validate_llm_settings!)
        expect(client.response.errors).to include(I18n.t("images.errors.messages.llm_not_configured"))
      end
    end

    context "when model is missing" do
      before { Setting["llm.model"] = nil }

      it "adds error to response" do
        client.send(:validate_llm_settings!)
        expect(client.response.errors).to include(I18n.t("images.errors.messages.llm_not_configured"))
      end
    end
  end

  describe "Response" do
    let(:response) { ImageSuggestions::Llm::Client::Response.new }

    it "initializes with empty results and errors" do
      expect(response.results).to eq([])
      expect(response.errors).to eq([])
    end

    it "allows setting results" do
      response.results = ["result1", "result2"]
      expect(response.results).to eq(["result1", "result2"])
    end

    it "allows adding errors" do
      response.errors << "error1"
      expect(response.errors).to include("error1")
    end
  end
end
