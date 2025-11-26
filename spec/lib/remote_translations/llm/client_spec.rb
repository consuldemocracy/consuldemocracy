require "rails_helper"

describe RemoteTranslations::Llm::Client do
  let(:chat) { instance_double(RubyLLM::Chat, ask: double(content: "translated")) }
  let(:config)  { instance_double(RubyLLM::Configuration) }
  let(:context) { instance_double(RubyLLM::Context, chat: chat, config: config) }
  let(:client) { RemoteTranslations::Llm::Client.new }

  before do
    Setting["llm.provider"] = "OpenAI"
    allow(Llm::Config).to receive(:context).and_return(context)
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
end
