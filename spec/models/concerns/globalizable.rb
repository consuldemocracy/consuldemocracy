require "spec_helper"

shared_examples_for "globalizable" do |factory_name|
  let(:record) do
    if factory_name == :budget_phase
      create(:budget).phases.last
    else
      create(factory_name)
    end
  end
  let(:fields) { record.translated_attribute_names }
  let(:required_fields) { fields.select { |field| record.send(:required_attribute?, field) } }
  let(:attribute) { required_fields.sample || fields.sample }

  before do
    record.update!(attribute => "In English")

    add_translation(record, :es, "En español")

    record.reload
  end

  describe "Add a translation" do
    it "Maintains existing translations" do
      record.update!(translations_attributes: [
        { locale: :fr }.merge(fields.index_with("En Français"))
      ])
      record.reload

      expect(record.send(attribute)).to eq "In English"
      I18n.with_locale(:es) { expect(record.send(attribute)).to eq "En español" }
      I18n.with_locale(:fr) { expect(record.send(attribute)).to eq "En Français" }
    end

    it "Works with non-underscored locale name" do
      record.update!(translations_attributes: [
        { locale: :"pt-BR" }.merge(fields.index_with("Português"))
      ])
      record.reload

      expect(record.send(attribute)).to eq "In English"
      I18n.with_locale(:es) { expect(record.send(attribute)).to eq "En español" }
      I18n.with_locale(:"pt-BR") { expect(record.send(attribute)).to eq "Português" }
    end

    it "Does not create invalid translations in the database" do
      if required_fields.any?
        record.update(translations_attributes: [{ locale: :fr }])

        expect(record.translations.map(&:locale)).to match_array %i[en es fr]

        record.reload

        expect(record.translations.map(&:locale)).to match_array %i[en es]
      end
    end

    it "Does not automatically add a translation for the current locale" do
      record.translations.destroy_all
      record.reload

      record.update!(translations_attributes: [
        { locale: :de }.merge(fields.index_with("Deutsche Sprache"))
      ])

      record.reload

      expect(record.translations.map(&:locale)).to eq [:de]
    end
  end

  describe "Update a translation" do
    it "Changes the existing translation" do
      record.update!(translations_attributes: [
        { id: record.translations.find_by(locale: :es).id, attribute => "Actualizado" }
      ])
      record.reload

      expect(record.send(attribute)).to eq "In English"
      I18n.with_locale(:es) { expect(record.send(attribute)).to eq "Actualizado" }
    end

    it "Does not save invalid translations" do
      if required_fields.any?
        record.update(translations_attributes: [
          { id: record.translations.find_by(locale: :es).id, attribute => "" }
        ])

        I18n.with_locale(:es) { expect(record.send(attribute)).to eq "" }

        record.reload

        I18n.with_locale(:es) { expect(record.send(attribute)).to eq "En español" }
      end
    end

    it "Does not automatically add a translation for the current locale" do
      destroy_translation(record, :en)
      record.reload

      record.update!(translations_attributes: [
        { id: record.translations.first.id }.merge(fields.index_with("Actualizado"))
      ])

      record.reload

      expect(record.translations.map(&:locale)).to eq [:es]
    end
  end

  describe "Remove a translation" do
    it "Keeps the other languages" do
      record.update!(translations_attributes: [
        { id: record.translations.find_by(locale: :en).id, _destroy: true }
      ])
      record.reload

      expect(record.translations.map(&:locale)).to eq [:es]
    end

    it "Does not remove all translations" do
      if required_fields.any?
        record.translations_attributes = [
          { id: record.translations.find_by(locale: :en).id, _destroy: true },
          { id: record.translations.find_by(locale: :es).id, _destroy: true }
        ]

        expect(record).not_to be_valid

        record.reload

        expect(record.translations.map(&:locale)).to match_array %i[en es]
      end
    end

    it "Does not remove translations when there's invalid data" do
      if required_fields.any?
        record.translations_attributes = [
          { id: record.translations.find_by(locale: :es).id, attribute => "" },
          { id: record.translations.find_by(locale: :en).id, _destroy: true }
        ]

        expect(record).not_to be_valid

        record.reload

        expect(record.translations.map(&:locale)).to match_array %i[en es]
      end
    end
  end

  describe "Fallbacks" do
    before do
      I18n.with_locale(:de) do
        record.update!(required_fields.index_with("Deutsche Sprache"))
        record.update!(attribute => "Deutsche Sprache")
      end
    end

    it "Falls back to a defined fallback" do
      allow(I18n.fallbacks).to receive(:[]).and_return([:fr, :es])
      Globalize.set_fallbacks_to_all_available_locales

      I18n.with_locale(:fr) do
        expect(record.send(attribute)).to eq "En español"
      end
    end

    it "Falls back to the first available locale without a defined fallback" do
      allow(I18n.fallbacks).to receive(:[]).and_return([:fr])
      Globalize.set_fallbacks_to_all_available_locales

      I18n.with_locale(:fr) do
        expect(record.send(attribute)).to eq "Deutsche Sprache"
      end
    end

    it "Falls back to the first available locale after removing a locale" do
      expect(record.send(attribute)).to eq "In English"

      record.update!(translations_attributes: [
        { id: record.translations.find_by(locale: :en).id, _destroy: true }
      ])

      expect(record.send(attribute)).to eq "Deutsche Sprache"
    end
  end

  describe ".with_fallback_translation" do
    before do
      fallbacks = { fr: %i[fr en es], es: %i[es fr en], en: %i[en es fr] }
      allow(I18n).to receive(:fallbacks).and_return(I18n.fallbacks.merge(fallbacks))
      Globalize.set_fallbacks_to_all_available_locales
    end

    it "returns records with the best fallback translation available for the current locale" do
      record.update!(attribute => "Content in English")
      add_translation(record, :es, "Contenido en español")
      add_translation(record, :fr, "Contenu en français")

      I18n.with_locale(:es) do
        expect(attribute_with_fallback_translation(record, attribute)).to eq "Contenido en español"

        destroy_translation(record, :es)

        expect(attribute_with_fallback_translation(record, attribute)).to eq "Contenu en français"

        destroy_translation(record, :fr)

        expect(attribute_with_fallback_translation(record, attribute)).to eq "Content in English"
      end

      record.reload

      add_translation(record, :es, "Contenido en español")
      add_translation(record, :fr, "Contenu en français")

      I18n.with_locale(:fr) do
        expect(attribute_with_fallback_translation(record, attribute)).to eq "Contenu en français"

        destroy_translation(record, :fr)

        expect(attribute_with_fallback_translation(record, attribute)).to eq "Content in English"

        destroy_translation(record, :en)

        expect(attribute_with_fallback_translation(record, attribute)).to eq "Contenido en español"
      end
    end
  end
end

def add_translation(record, locale, text)
  I18n.with_locale(locale) do
    record.update!(required_fields.index_with(text))
    record.update!(attribute => text)
  end
end

def destroy_translation(record, locale)
  record.translations.find_by(locale: locale).destroy!
end

def attribute_with_fallback_translation(record, attribute)
  record.class.with_fallback_translation.where(id: record.id).pick(attribute)
end
