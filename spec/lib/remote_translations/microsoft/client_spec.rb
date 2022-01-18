require "rails_helper"

describe RemoteTranslations::Microsoft::Client do
  let(:client) { RemoteTranslations::Microsoft::Client.new }

  describe "#call" do
    context "when characters from request are less than the characters limit" do
      it "response has the expected result" do
        response = create_response("Nuevo título", "Nueva descripción")

        expect_any_instance_of(TranslatorText::Client).to receive(:translate).and_return(response)

        result = client.call(["New title", "New description"], :es)

        expect(result).to eq(["Nuevo título", "Nueva descripción"])
      end

      it "response nil has the expected result when request has nil value" do
        response = create_response("Notranslate", "Nueva descripción")

        expect_any_instance_of(TranslatorText::Client).to receive(:translate).and_return(response)

        result = client.call([nil, "New description"], :es)

        expect(result).to eq([nil, "Nueva descripción"])
      end
    end

    context "when characters from request are greater than characters limit" do
      it "response has the expected result when the request has 2 texts, where both less than CHARACTERS_LIMIT_PER_REQUEST" do
        stub_const("RemoteTranslations::Microsoft::Client::CHARACTERS_LIMIT_PER_REQUEST", 20)
        text_en = Faker::Lorem.characters(number: 11)
        another_text_en = Faker::Lorem.characters(number: 11)

        translated_text_es = Faker::Lorem.characters(number: 11)
        another_translated_text_es = Faker::Lorem.characters(number: 11)
        response_text = create_response(translated_text_es)
        response_another_text = create_response(another_translated_text_es)

        expect_any_instance_of(TranslatorText::Client).to receive(:translate).exactly(1)
                                                                             .times
                                                                             .and_return(response_text)
        expect_any_instance_of(TranslatorText::Client).to receive(:translate).exactly(1)
                                                                             .times
                                                                             .and_return(response_another_text)

        result = client.call([text_en, another_text_en], :es)

        expect(result).to eq([translated_text_es, another_translated_text_es])
      end

      it "response has the expected result when the request has 2 texts and both are greater than CHARACTERS_LIMIT_PER_REQUEST" do
        stub_const("RemoteTranslations::Microsoft::Client::CHARACTERS_LIMIT_PER_REQUEST", 20)
        start_text_en = Faker::Lorem.characters(number: 10) + " "
        end_text_en = Faker::Lorem.characters(number: 10)
        text_en = start_text_en + end_text_en

        start_translated_text_es = Faker::Lorem.characters(number: 10) + " "
        end_translated_text_es = Faker::Lorem.characters(number: 10)
        translated_text_es = start_translated_text_es + end_translated_text_es
        response_start_text = create_response(start_translated_text_es)
        response_end_text = create_response(end_translated_text_es)

        expect_any_instance_of(TranslatorText::Client).to receive(:translate).with([start_text_en], to: :es)
                                                                             .exactly(1)
                                                                             .times
                                                                             .and_return(response_start_text)
        expect_any_instance_of(TranslatorText::Client).to receive(:translate).with([end_text_en], to: :es)
                                                                             .exactly(1)
                                                                             .times
                                                                             .and_return(response_end_text)

        start_another_text_en = Faker::Lorem.characters(number: 12) + "."
        end_another_text_en = Faker::Lorem.characters(number: 12)
        another_text_en = start_another_text_en + end_another_text_en

        another_start_translated_text_es = Faker::Lorem.characters(number: 12) + "."
        another_end_translated_text_es = Faker::Lorem.characters(number: 12)
        another_translated_text_es = another_start_translated_text_es + another_end_translated_text_es
        response_another_start_text = create_response(another_start_translated_text_es)
        response_another_end_text = create_response(another_end_translated_text_es)

        expect_any_instance_of(TranslatorText::Client).to receive(:translate).with([start_another_text_en], to: :es)
                                                                             .exactly(1)
                                                                             .times
                                                                             .and_return(response_another_start_text)
        expect_any_instance_of(TranslatorText::Client).to receive(:translate).with([end_another_text_en], to: :es)
                                                                             .exactly(1)
                                                                             .times
                                                                             .and_return(response_another_end_text)

        result = client.call([text_en, another_text_en], :es)

        expect(result).to eq([translated_text_es, another_translated_text_es])
      end
    end
  end

  describe "#detect_split_position" do
    context "text has less characters than characters limit" do
      it "does not split the text" do
        stub_const("RemoteTranslations::Microsoft::Client::CHARACTERS_LIMIT_PER_REQUEST", 20)
        text_to_translate = Faker::Lorem.characters(number: 10)

        result = client.fragments_for(text_to_translate)

        expect(result).to eq [text_to_translate]
      end
    end

    context "text has more characters than characters limit" do
      it "to split text by first valid dot when there is a dot for split" do
        stub_const("RemoteTranslations::Microsoft::Client::CHARACTERS_LIMIT_PER_REQUEST", 20)
        start_text = Faker::Lorem.characters(number: 10) + "."
        end_text = Faker::Lorem.characters(number: 10)
        text_to_translate = start_text + end_text

        result = client.fragments_for(text_to_translate)

        expect(result).to eq([start_text, end_text])
      end

      it "to split text by first valid space when there is not a dot for split but there is a space" do
        stub_const("RemoteTranslations::Microsoft::Client::CHARACTERS_LIMIT_PER_REQUEST", 20)
        start_text = Faker::Lorem.characters(number: 10) + " "
        end_text = Faker::Lorem.characters(number: 10)
        text_to_translate = start_text + end_text

        result = client.fragments_for(text_to_translate)

        expect(result).to eq([start_text, end_text])
      end

      it "to split text in the middle of a word when there are not valid dots and spaces" do
        stub_const("RemoteTranslations::Microsoft::Client::CHARACTERS_LIMIT_PER_REQUEST", 40)
        sub_part_text_1 = Faker::Lorem.characters(number: 5) + " ."
        sub_part_text_2 = Faker::Lorem.characters(number: 5)
        sub_part_text_3 = Faker::Lorem.characters(number: 9)
        sub_part_text_4 = Faker::Lorem.characters(number: 30)
        text_to_translate = sub_part_text_1 + sub_part_text_2 + sub_part_text_3 + sub_part_text_4

        result = client.fragments_for(text_to_translate)

        expect(result).to eq([sub_part_text_1 + sub_part_text_2, sub_part_text_3 + sub_part_text_4])
      end
    end
  end
end

def create_response(*args)
  # response = [#<TranslatorText::Types::TranslationResult translations=[#<TranslatorText::Types::Translation text="Nuevo título" to=:es>] detectedLanguage={"language"=>"en", "score"=>1.0}>, #<TranslatorText::Types::TranslationResult translations=[#<TranslatorText::Types::Translation text="Nueva descripción" to=:es>] detectedLanguage={"language"=>"en", "score"=>1.0}>]
  translations = Struct.new(:translations)
  text = Struct.new(:text)
  response = []

  args.each do |text_to_response|
    response << translations.new([text.new(text_to_response)])
  end

  response
end
