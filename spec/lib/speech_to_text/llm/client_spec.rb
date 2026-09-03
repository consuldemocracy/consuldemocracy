require "rails_helper"

describe SpeechToText::Llm::Client do
  let(:audio_file) do
    fixture_file_upload("clippy.jpg", "audio/webm").tap do |file|
      allow(file).to receive(:original_filename).and_return("recording.webm")
    end
  end
  let(:transcription) { double(text: " dictated text ") }
  let(:context) { double("RubyLLM::Context") }

  before do
    stub_secrets(llm: { openai_api_key: "1234" })
    Setting["llm.use_llm_speech_to_text"] = true
    Setting["llm.speech_to_text_provider"] = "OpenAI"
    Setting["llm.speech_to_text_model"] = "whisper-1"
    allow(Llm::Config).to receive_messages(context: context, speech_to_text_configured?: true)
    allow(RubyLLM).to receive(:transcribe).and_return(transcription)
  end

  describe "#call" do
    subject(:response) { SpeechToText::Llm::Client.new(audio_file: audio_file, locale: locale).call }

    let(:locale) { "en" }

    it "returns stripped text from a named tempfile with the model and locale language" do
      expect(RubyLLM).to receive(:transcribe) do |audio, **options|
        expect(File.extname(audio.path)).to eq(".webm")
        expect(options).to eq(
          model: "whisper-1",
          language: "en",
          provider: :openai,
          context: context
        )
        transcription
      end

      expect(response.text).to eq("dictated text")
      expect(response.errors).to be_empty
    end

    context "when transcription text is nil" do
      let(:transcription) { double(text: nil) }

      it "returns an empty string" do
        expect(response.text).to eq("")
        expect(response.errors).to be_empty
      end
    end

    context "when locale includes region" do
      let(:locale) { "sv-SE" }

      it "uses only the language part" do
        response

        expect(RubyLLM).to have_received(:transcribe).with(
          anything,
          model: "whisper-1",
          language: "sv",
          provider: :openai,
          context: context
        )
      end
    end

    context "when the audio uses the MP4 content type" do
      before do
        allow(audio_file).to receive_messages(
          content_type: "audio/mp4",
          original_filename: "recording.mp4"
        )
      end

      it "uses an audio-specific extension for the tempfile" do
        expect(RubyLLM).to receive(:transcribe) do |audio, **_options|
          expect(File.extname(audio.path)).to eq(".m4a")
          transcription
        end

        response
      end
    end

    context "when speech-to-text is not configured" do
      before do
        allow(Llm::Config).to receive(:speech_to_text_configured?).and_return(false)
      end

      it "returns a configuration error" do
        expect(response.text).to be(nil)
        expect(response.errors).to include(
          "Speech to text is not configured. Please contact an administrator."
        )
      end
    end

    context "when the provider is not configured" do
      before do
        allow(RubyLLM).to receive(:transcribe)
          .and_raise(RubyLLM::ConfigurationError, "OpenAI provider is not configured")
      end

      it "returns a configuration error" do
        expect(response.text).to be(nil)
        expect(response.errors).to include(
          "Speech to text is not configured. Please contact an administrator."
        )
      end
    end

    context "when transcription raises an error" do
      before do
        allow(RubyLLM).to receive(:transcribe).and_raise(RubyLLM::Error, "API error")
      end

      it "returns a generic transcription error" do
        expect(response.text).to be(nil)
        expect(response.errors).to include("Transcription failed. Please try again.")
      end
    end

    context "when an unexpected error occurs" do
      before do
        allow(RubyLLM).to receive(:transcribe).and_raise(RuntimeError, "unexpected failure")
      end

      it "returns a generic transcription error" do
        expect(response.text).to be(nil)
        expect(response.errors).to include("Transcription failed. Please try again.")
      end
    end

    context "when the model is not found" do
      before do
        allow(RubyLLM).to receive(:transcribe)
          .and_raise(RubyLLM::ModelNotFoundError, "missing model")
      end

      it "returns a generic transcription error" do
        expect(response.text).to be(nil)
        expect(response.errors).to include("Transcription failed. Please try again.")
      end
    end

    context "when the attachment is unsupported" do
      before do
        allow(RubyLLM).to receive(:transcribe)
          .and_raise(RubyLLM::UnsupportedAttachmentError, "audio/webm")
      end

      it "returns a generic transcription error" do
        expect(response.text).to be(nil)
        expect(response.errors).to include("Transcription failed. Please try again.")
      end
    end

    context "when the provider connection fails" do
      before do
        allow(RubyLLM).to receive(:transcribe)
          .and_raise(Faraday::ConnectionFailed, "Connection failed")
      end

      it "returns a generic transcription error" do
        expect(response.text).to be(nil)
        expect(response.errors).to include("Transcription failed. Please try again.")
      end
    end
  end
end
