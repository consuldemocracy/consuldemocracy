require 'rails_helper'

describe MicrosoftTranslateClient do

  let(:microsoft_client) { described_class.new }

  describe '#call' do

    context 'when characters from request are less than the characters limit' do

      it 'response has the expected result' do
        response = create_response("Nuevo título", "Nueva descripción")

        expect_any_instance_of(TranslatorText::Client).to receive(:translate).and_return(response)

        result = microsoft_client.call([ "New title", "New description"], :es)

        expect(result).to eq(["Nuevo título", "Nueva descripción"])
      end

      it 'response nil has the expected result when request has nil value' do
        response = create_response("Notranslate", "Nueva descripción")

        expect_any_instance_of(TranslatorText::Client).to receive(:translate).and_return(response)

        result = microsoft_client.call([nil, "Nueva descripción"], :es)

        expect(result).to eq([nil, "Nueva descripción"])
      end

    end

    context 'when characters from request are greater than characters limit' do

      it 'response has the expected result when the request has 2 texts, where both less than CHARACTERS_LIMIT_PER_REQUEST' do
        stub_const("MicrosoftTranslateClient::CHARACTERS_LIMIT_PER_REQUEST", 20)
        text = Faker::Lorem.characters(11)
        another_text = Faker::Lorem.characters(11)
        response_text = create_response(text)
        response_another_text = create_response(another_text)

        expect_any_instance_of(TranslatorText::Client).to receive(:translate).exactly(1).times.and_return(response_text)
        expect_any_instance_of(TranslatorText::Client).to receive(:translate).exactly(1).times.and_return(response_another_text)

        result = microsoft_client.call([text, another_text], :es)

        expect(result).to eq([text, another_text])
      end

      it 'response has the expected result when the request has 1 texts and it is greater than CHARACTERS_LIMIT_PER_REQUEST' do
        stub_const("MicrosoftTranslateClient::CHARACTERS_LIMIT_PER_REQUEST", 20)
        start_text = Faker::Lorem.characters(10) + "."
        end_text = Faker::Lorem.characters(10)
        text_to_translate = start_text + end_text
        response_start_text = create_response(start_text)
        response_end_text = create_response(end_text)

        expect_any_instance_of(TranslatorText::Client).to receive(:translate).with([start_text], to: :es).exactly(1).times.and_return(response_start_text)
        expect_any_instance_of(TranslatorText::Client).to receive(:translate).with([end_text], to: :es).exactly(1).times.and_return(response_end_text)

        result = microsoft_client.call([text_to_translate], :es)

        expect(result).to eq([text_to_translate])
      end

      it 'response has the expected result when the request has 2 texts and both are greater than CHARACTERS_LIMIT_PER_REQUEST' do
        stub_const("MicrosoftTranslateClient::CHARACTERS_LIMIT_PER_REQUEST", 20)
        start_text = Faker::Lorem.characters(10) + " "
        end_text = Faker::Lorem.characters(10)
        text_to_translate = start_text + end_text
        response_start_text = create_response(start_text)
        response_end_text = create_response(end_text)

        expect_any_instance_of(TranslatorText::Client).to receive(:translate).with([start_text], to: :es).exactly(1).times.and_return(response_start_text)
        expect_any_instance_of(TranslatorText::Client).to receive(:translate).with([end_text], to: :es).exactly(1).times.and_return(response_end_text)

        another_start_text = Faker::Lorem.characters(12) + "."
        another_end_text = Faker::Lorem.characters(12)
        another_text_to_translate = another_start_text + another_end_text
        response_another_start_text = create_response(another_start_text)
        response_another_end_text = create_response(another_end_text)

        expect_any_instance_of(TranslatorText::Client).to receive(:translate).with([another_start_text], to: :es).exactly(1).times.and_return(response_another_start_text)
        expect_any_instance_of(TranslatorText::Client).to receive(:translate).with([another_end_text], to: :es).exactly(1).times.and_return(response_another_end_text)

        result = microsoft_client.call([text_to_translate, another_text_to_translate], :es)

        expect(result).to eq([text_to_translate, another_text_to_translate])
      end

    end

  end

  describe '#detect_split_position' do

    context 'when text to translate is greater than CHARACTERS_LIMIT_PER_REQUEST' do

      it 'to split text by first valid dot when there is a dot for split' do
        stub_const("MicrosoftTranslateClient::CHARACTERS_LIMIT_PER_REQUEST", 40)
        start_text = Faker::Lorem.characters(10) + "sample text."
        end_text = Faker::Lorem.characters(10) + "more sample text."
        text_to_translate = start_text + end_text
        response_start_text = create_response(start_text)
        response_end_text = create_response(end_text)

        expect_any_instance_of(TranslatorText::Client).to receive(:translate).with([start_text], to: :es).exactly(1).times.and_return(response_start_text)
        expect_any_instance_of(TranslatorText::Client).to receive(:translate).with([end_text], to: :es).exactly(1).times.and_return(response_end_text)

        result = microsoft_client.call([text_to_translate], :es)

        expect(result).to eq([text_to_translate])
      end

      it 'to split text by first valid space when there is not a dot for split but there is a space' do
        stub_const("MicrosoftTranslateClient::CHARACTERS_LIMIT_PER_REQUEST", 40)
        start_text = Faker::Lorem.characters(10) + "sampletext "
        end_text = Faker::Lorem.characters(10) + "more sample text"
        text_to_translate = start_text + end_text
        response_start_text = create_response(start_text)
        response_end_text = create_response(end_text)

        expect_any_instance_of(TranslatorText::Client).to receive(:translate).with([start_text], to: :es).exactly(1).times.and_return(response_start_text)
        expect_any_instance_of(TranslatorText::Client).to receive(:translate).with([end_text], to: :es).exactly(1).times.and_return(response_end_text)

        result = microsoft_client.call([text_to_translate], :es)

        expect(result).to eq([text_to_translate])
      end

      it 'to split text in the middle of a word when there are not valids dots and spaces' do
        stub_const("MicrosoftTranslateClient::CHARACTERS_LIMIT_PER_REQUEST", 40)
        sub_part_text_1 = Faker::Lorem.characters(5) + " ."
        sub_part_text_2 = Faker::Lorem.characters(5)
        sub_part_text_3 = Faker::Lorem.characters(9)
        sub_part_text_4 = Faker::Lorem.characters(30)
        text_to_translate = sub_part_text_1 + sub_part_text_2 + sub_part_text_3 + sub_part_text_4

        response_start_text = create_response(sub_part_text_1 + sub_part_text_2)
        response_end_text = create_response(sub_part_text_3 + sub_part_text_4)

        expect_any_instance_of(TranslatorText::Client).to receive(:translate).with([sub_part_text_1 + sub_part_text_2], to: :es).exactly(1).times.and_return(response_start_text)
        expect_any_instance_of(TranslatorText::Client).to receive(:translate).with([sub_part_text_3 + sub_part_text_4], to: :es).exactly(1).times.and_return(response_end_text)

        result = microsoft_client.call([text_to_translate], :es)

        expect(result).to eq([text_to_translate])
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
