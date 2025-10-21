require "rails_helper"

describe RemoteTranslations::Llm::Client do
  let(:chat_double) { double("chat", ask: double(content: "translated")) }

  before do
    Setting["llm.provider"] = "OpenAI"
    Setting["llm.model"] = "gpt-4o-mini"
    Setting["llm.use_llm_for_translations"] = true

    allow(YAML).to receive(:load_file).and_return(
      { "remote_translation_prompt" => "Please translate to %{output_locale}: %{input_text}" }
    )
    allow(RubyLLM).to receive_message_chain(:models, :find).and_return(double(context_window: 10_000))
    allow_any_instance_of(RemoteTranslations::Llm::Config).to receive(:context).and_call_original
    allow(RemoteTranslations::Llm::Config).to receive(:context).and_return(double(chat: chat_double,
                                                                                  config: double))
  end

  # Ensure memoized context from RemoteTranslations::Llm::Config doesn't leak doubles
  after do
    if RemoteTranslations::Llm::Config.instance_variable_defined?(:@context)
      RemoteTranslations::Llm::Config.remove_instance_variable(:@context)
    end
  end

  it "calls chat.ask for each field and returns contents" do
    client = RemoteTranslations::Llm::Client.new
    result = client.call(["Hello", "World"], "es")

    expect(result).to eq(["translated", "translated"])
  end
end
