require "rails_helper"

describe RemoteTranslations::Llm::Client do
  let(:chat) { double(ask: double(content: "translated")) }
  let(:client) { RemoteTranslations::Llm::Client.new }

  before do
    Setting["llm.provider"] = "OpenAI"
    allow(Llm::Config).to receive(:chat).and_return(chat)
  end

  it "calls chat.ask for each field and returns contents" do
    result = client.call(["Hello", "World"], "es")

    expect(result).to eq ["translated", "translated"]
  end

  it "interpolates the prompt with the expected text" do
    allow(YAML).to receive(:load_file).and_return(
      { "remote_translation_prompt" => "Please translate to %{output_locale}: %{input_text}" }
    )
    expect(chat).to receive(:ask).with("Please translate to es: Hello")
                                 .and_return(double(content: "translated"))
    expect(chat).to receive(:ask).with("Please translate to es: World")
                                 .and_return(double(content: "translated"))

    result = client.call(["Hello", "World"], "es")

    expect(result).to eq ["translated", "translated"]
  end

  it "logs and re-raises errors from the LLM provider" do
    allow(Rails.logger).to receive(:error)
    allow(chat).to receive(:ask).and_raise(RubyLLM::BadRequestError.new(nil, "Model deprecated"))

    expect { client.call(["Hello"], "es") }.to raise_error(RubyLLM::BadRequestError)
    expect(Rails.logger).to have_received(:error).with(
      "LLM remote translation to es failed: RubyLLM::BadRequestError: Model deprecated"
    )
  end
end
