require "rails_helper"
require "i18n/tasks"

describe "I18n" do
  let(:i18n) { I18n::Tasks::BaseTask.new }
  let(:missing_keys) { i18n.missing_keys }
  let(:unused_keys) { i18n.unused_keys }

  it "does not have missing keys" do
    expect(missing_keys).to be_empty,
      "Missing #{missing_keys.leaves.count} i18n keys, run `i18n-tasks missing' to show them"
  end

  it "does not have unused keys" do
    expect(unused_keys).to be_empty,
      "#{unused_keys.leaves.count} unused i18n keys, run `i18n-tasks unused' to show them"
  end

  context "Plurals" do
    after do
      I18n.backend.reload!
    end

    it "returns plural rule if translation present" do
      keys = { zero: "No comments", one: "1 comment", other: "%{count} comments" }

      I18n.backend.store_translations(:en, { test_plural: keys })

      expect(I18n.t("test_plural", count: 0)).to eq("No comments")
      expect(I18n.t("test_plural", count: 1)).to eq("1 comment")
      expect(I18n.t("test_plural", count: 2)).to eq("2 comments")
    end

    it "returns default locale's plural rule if whole translation not present" do
      keys = { zero: "No comments", one: "1 comment", other: "%{count} comments" }

      I18n.backend.store_translations(I18n.default_locale, { test_plural: keys })
      I18n.backend.store_translations(:zz, {})

      default_enforce = I18n.enforce_available_locales

      begin
        I18n.enforce_available_locales = false
        I18n.with_locale(:zz) do
          I18n.fallbacks[:zz] << I18n.default_locale

          expect(I18n.t("test_plural", count: 0)).to eq("No comments")
          expect(I18n.t("test_plural", count: 1)).to eq("1 comment")
          expect(I18n.t("test_plural", count: 2)).to eq("2 comments")
        end
      ensure
        I18n.enforce_available_locales = default_enforce
      end
    end

    it "returns count if specific plural rule not present" do
      keys = { zero:  "No comments" }
      I18n.backend.store_translations(:en, { test_plural: keys })

      expect(I18n.t("test_plural", count: 0)).to eq("No comments")
      expect(I18n.t("test_plural", count: 1)).to eq("1")
      expect(I18n.t("test_plural", count: 2)).to eq("2")
    end

    it "returns a String to avoid exception 'undefined method for Fixnum'" do
      keys = { zero: "No comments" }
      I18n.backend.store_translations(:en, { test_plural: keys })

      result = I18n.t("test_plural", count: 1)
      expect(result.class).to be String
      expect { result.pluralize }.not_to raise_error
    end

    it "returns the number not pluralized for missing translations" do
      keys = { zero: "No comments" }
      I18n.backend.store_translations(:en, { test_plural: keys })

      expect(I18n.t("test_plural", count: 1).pluralize).to eq "1"
      expect(I18n.t("test_plural", count: 2).pluralize).to eq "2"
      expect(I18n.t("test_plural", count: 1).pluralize).not_to eq "1s"
      expect(I18n.t("test_plural", count: 2).pluralize).not_to eq "2s"
    end
  end
end
