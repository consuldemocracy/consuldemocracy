require "spec_helper"

shared_examples_for "globalizable" do |factory_name|
  let(:record) { create(factory_name) }
  let(:fields) { record.translated_attribute_names }
  let(:attribute) { fields.sample }

  describe "Fallbacks" do
    before do
      record.update_attribute(attribute, "In English")

      { es: "En español", de: "Deutsch" }.each do |locale, text|
        Globalize.with_locale(locale) do
          fields.each do |field|
            record.update_attribute(field, record.send(field))
          end

          record.update_attribute(attribute, text)
        end
      end
    end

    it "Falls back to a defined fallback" do
      allow(I18n.fallbacks).to receive(:[]).and_return([:fr, :es])
      Globalize.set_fallbacks_to_all_available_locales

      Globalize.with_locale(:fr) do
        expect(record.send(attribute)).to eq "En español"
      end
    end

    it "Falls back to the first available locale without a defined fallback" do
      allow(I18n.fallbacks).to receive(:[]).and_return([:fr])
      Globalize.set_fallbacks_to_all_available_locales

      Globalize.with_locale(:fr) do
        expect(record.send(attribute)).to eq "Deutsch"
      end
    end
  end
end
