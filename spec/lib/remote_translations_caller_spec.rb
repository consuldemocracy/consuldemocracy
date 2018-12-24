require 'rails_helper'

describe RemoteTranslationsCaller do
  let(:remote_translation_caller) { described_class.new }
  let(:debate)           { create(:debate) }
  let(:remote_translation) { create(:remote_translation, remote_translatable: debate, locale: :es) }

  before do
    RemoteTranslation.skip_callback(:create, :after, :enqueue_remote_translation)
  end
  describe '#call' do

    it 'returns the resource with new translation persisted' do
      microsoft_translate_client_response = [ "Nuevo título", "Nueva descripción"]
      expect_any_instance_of(MicrosoftTranslateClient).to receive(:call).and_return(microsoft_translate_client_response)

      remote_translation_caller.call(remote_translation)

      expect(debate.translations.count).to eq(2)
    end

    it "destroy remote translation instance" do
      microsoft_translate_client_response = [ "Nuevo título", "Nueva descripción"]
      expect_any_instance_of(MicrosoftTranslateClient).to receive(:call).and_return(microsoft_translate_client_response)

      remote_translation_caller.call(remote_translation)

      expect(RemoteTranslation.count).to eq(0)
    end

    it "when resource is invalid update error_messages" do
      microsoft_translate_client_response = [ "Si", "Nueva descripción"]
      expect_any_instance_of(MicrosoftTranslateClient).to receive(:call).and_return(microsoft_translate_client_response)

      remote_translation_caller.call(remote_translation)

      expect(remote_translation.error_message).to include("is too short (minimum is 4 characters)")
    end

  end

end
