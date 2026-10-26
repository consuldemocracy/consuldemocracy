require "rails_helper"

describe Globalizable do
  before do
    dummy_banner = Class.new(ApplicationRecord) do
      def self.name
        "DummyBanner"
      end
      self.table_name = "banners"

      translates :title, touch: true
      translates :description, touch: true
      include Globalizable

      has_many :translations, class_name: "DummyBanner::Translation",
                              foreign_key: "banner_id",
                              autosave: true

      validates_translation :title, presence: true, length: { minimum: 7 }
      validates_translation :description, presence: true
    end

    stub_const("DummyBanner", dummy_banner)
  end

  it "keeps the flat value when nested attributes send an invalid one" do
    dummy = DummyBanner.create!(title: "Long enough", description: "Present")

    updated = dummy.update(
      title: "Flat title",
      translations_attributes: [{ id: dummy.translations.first.id, title: "" }]
    )

    expect(updated).to be true
    expect(dummy.reload.title).to eq "Flat title"
  end

  it "validates the flat value when nested attributes send a valid one" do
    dummy = DummyBanner.create!(title: "Long enough", description: "Present")

    updated = dummy.update(
      title: "",
      translations_attributes: [{ id: dummy.translations.first.id, title: "Nested title" }]
    )

    expect(updated).to be false
    expect(dummy.errors[:title]).to include "can't be blank"
    expect(dummy.errors[:"translations.title"]).to be_blank
    expect(dummy.reload.title).to eq "Long enough"
  end

  describe ".validates_translation" do
    it "validates length for the default locale" do
      Setting["locales.default"] = "es"

      dummy = DummyBanner.new
      dummy.translations.build(locale: "es", title: "Short")
      dummy.translations.build(locale: "fr", title: "Long enough")

      I18n.with_locale(:fr) do
        expect(dummy).not_to be_valid
      end
    end

    it "does not validate length for other locales" do
      Setting["locales.default"] = "es"

      dummy = DummyBanner.new
      dummy.translations.build(locale: "es", title: "Long enough", description: "Present")
      dummy.translations.build(locale: "fr", title: "Long enough", description: "Present")
      dummy.translations.build(locale: "en", title: "Short", description: "Present")

      I18n.with_locale(:fr) do
        expect(dummy).to be_valid
      end
    end

    it "adds an error to invalid attributes when another translation exists" do
      dummy = DummyBanner.create!(title: "Long enough", description: "Present")

      I18n.with_locale(:es) do
        dummy.update!(title: "Título original", description: "Una descripción")
      end

      expect(dummy.update(title: nil)).to be false
      expect(dummy.errors[:title]).to include "can't be blank"
      expect(dummy.errors[:"translations.title"]).to be_blank
      expect(dummy.reload.title).to eq "Long enough"
    end

    it "adds an error when a new translation is missing a required attribute" do
      dummy = DummyBanner.create!(title: "Long enough", description: "Present")

      updated = I18n.with_locale(:es) { dummy.update(title: "Título en español") }

      expect(updated).to be false
      expect(dummy.errors[:description]).to include "can't be blank"
      expect(dummy.errors[:"translations.description"]).to be_blank
      expect(dummy.reload.translations.map(&:locale)).to eq [:en]
    end
  end

  describe "validation error placement creating a record" do
    it "adds the error to the attribute when it is sent directly" do
      dummy = DummyBanner.new(title: "Short", description: "Present")

      expect(dummy).not_to be_valid
      expect(dummy.errors.count).to eq 1
      expect(dummy.errors[:title]).to be_present
      expect(dummy.errors["translations.title"]).to be_blank
    end

    it "adds the error to the translations when it is sent through the translations" do
      dummy = DummyBanner.new(translations_attributes: [{ locale: "en",
                                                          title: "Short",
                                                          description: "Present" }])

      expect(dummy).not_to be_valid
      expect(dummy.errors.count).to eq 1
      expect(dummy.errors["translations.title"]).to be_present
      expect(dummy.errors[:title]).to be_blank
    end
  end

  describe "validation error placement on direct and nested translation updates" do
    let(:dummy) { DummyBanner.create!(title: "Long enough", description: "Present") }

    it "adds the error to the attributes when they are sent directly" do
      dummy.update(title: "Short")

      expect(dummy.errors.count).to eq 1
      expect(dummy.errors[:title]).to eq ["is too short (minimum is 7 characters)"]
      expect(dummy.errors["translations.title"]).to be_blank
      expect(dummy.reload.title).to eq "Long enough"
    end

    it "keeps the locale in error messages when the attribute is sent directly" do
      I18n.with_locale(:es) do
        expect(dummy.update(title: "")).to be false
        expect(dummy.errors[:title]).to include "no puede estar en blanco"
        expect(dummy.errors.full_messages.join).to include "no puede estar en blanco"
      end
    end

    it "adds the error to the translations when the attribute is sent through translations" do
      dummy.update(translations_attributes: [{ id: dummy.translations.first.id,
                                               title: "Short",
                                               description: "Present" }])

      expect(dummy.errors.count).to eq 1
      expect(dummy.errors["translations.title"]).to be_present
      expect(dummy.errors[:title]).to be_blank
    end

    it "adds errors to the translation when using globalize accessors" do
      I18n.with_locale(:es) { dummy.update!(title: "Título en español", description: "Descripción") }

      expect(dummy.update(title_es: "")).to be false
      expect(dummy.errors[:"translations.title"]).to include "can't be blank"
      expect(dummy.errors[:title]).to be_blank
      expect(dummy.reload.title_es).to eq "Título en español"
    end

    it "adds the minimum translation error to the base attribute" do
      updated = dummy.update(
        title: "",
        translations_attributes: [{ id: dummy.translations.first.id, _destroy: "1" }]
      )
      translation = dummy.translations.find(&:marked_for_destruction?)

      expect(updated).to be false
      expect(dummy.errors[:base]).to eq ["It's mandatory to provide at least one translation"]
      expect(translation.errors[:base]).to eq ["It's mandatory to provide at least one translation"]
    end

    it "clears error messages after a valid update following an invalid one" do
      expect(dummy.update(title: "")).to be false
      expect(dummy.update(title: "Updated title")).to be true
      expect(dummy.errors).to be_empty
      expect(dummy.reload.title).to eq "Updated title"
    end

    context "custom validations" do
      before do
        DummyBanner.translation_class.class_eval do
          validate do
            errors.add(:title, "cannot be forbidden") if title == "Forbidden"
          end
        end
      end

      it "adds a custom validation error to the attribute when the attributes are sent directly" do
        expect(dummy.update(title: "Forbidden")).to be false
        expect(dummy.errors[:title]).to eq ["cannot be forbidden"]
        expect(dummy.errors[:"translations.title"]).to be_blank
      end

      it "adds errors when directly updating the current locale and another locale at the same time" do
        I18n.with_locale(:es) { dummy.update!(title: "Título en español", description: "Descripción") }
        spanish = dummy.translations.find_by!(locale: "es")

        updated = dummy.update(
          title: "",
          translations_attributes: [{ id: spanish.id, title: "Forbidden" }]
        )

        expect(updated).to be false
        expect(dummy.errors[:title]).to include("can't be blank",
                                                "is too short (minimum is 7 characters)")
        expect(dummy.errors[:title].length).to eq 2
        expect(dummy.errors[:"translations.title"]).to eq ["cannot be forbidden"]
      end
    end
  end
end
