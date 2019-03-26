require "rails_helper"

RSpec.describe I18nContent, type: :model do
  let(:i18n_content) { build(:i18n_content) }

  it "is valid" do
    expect(i18n_content).to be_valid
  end

  it "is not valid if key is not unique" do
    new_content = create(:i18n_content)

    expect(i18n_content).not_to be_valid
    expect(i18n_content.errors.size).to eq(1)
  end

  context "Scopes" do
    it "return one record when #by_key is used" do
      content      = create(:i18n_content)
      key          = "debates.form.debate_title"
      debate_title = create(:i18n_content, key: key)

      expect(I18nContent.all.size).to eq(2)

      query = I18nContent.by_key(key)

      expect(query.size).to eq(1)
      expect(query).to eq([debate_title])
    end

    it "return all matching records when #begins_with_key is used" do
      debate_text    = create(:i18n_content, key: "debates.form.debate_text")
      debate_title   = create(:i18n_content, key: "debates.form.debate_title")
      proposal_title = create(:i18n_content, key: "proposals.form.proposal_title")

      expect(I18nContent.all.size).to eq(3)

      query = I18nContent.begins_with_key("debates")

      expect(query.size).to eq(2)
      expect(query).to eq([debate_text, debate_title])
      expect(query).not_to include(proposal_title)
    end
  end

  context "Globalize" do
    it "translates key into multiple languages" do
      key = "devise_views.mailer.confirmation_instructions.welcome"
      welcome = build(:i18n_content, key: key, value_en: "Welcome", value_es: "Bienvenido")

      expect(welcome.value_en).to eq("Welcome")
      expect(welcome.value_es).to eq("Bienvenido")
    end

    it "responds to locales defined on model" do
      expect(i18n_content).to respond_to(:value_en)
      expect(i18n_content).to respond_to(:value_es)
      expect(i18n_content).not_to respond_to(:value_wl)
    end

    it "returns nil if translations are not available" do
      expect(i18n_content.value_en).to eq("Text in english")
      expect(i18n_content.value_es).to eq("Texto en español")
      expect(i18n_content.value_nl).to be(nil)
      expect(i18n_content.value_fr).to be(nil)
    end

    it "responds accordingly to the current locale" do
      expect(i18n_content.value).to eq("Text in english")

      Globalize.locale = :es

      expect(i18n_content.value).to eq("Texto en español")
    end
  end

  describe "#flat_hash" do
    it "uses one parameter" do
      expect(I18nContent.flat_hash(nil)).to eq({
        nil => nil
      })

      expect(I18nContent.flat_hash("string")).to eq({
        nil => "string"
      })

      expect(I18nContent.flat_hash({ w: "string" })).to eq({
        "w" => "string"
      })

      expect(I18nContent.flat_hash({ w: { p: "string" } })).to eq({
        "w.p" => "string"
      })
    end

    it "uses the first two parameters" do
      expect(I18nContent.flat_hash("string", "f")).to eq({
        "f" => "string"
      })

      expect(I18nContent.flat_hash(nil, "f")).to eq({
        "f" => nil
      })

      expect(I18nContent.flat_hash({ w: "string" }, "f")).to eq({
        "f.w" => "string"
      })

      expect(I18nContent.flat_hash({ w: { p: "string" } }, "f")).to eq({
        "f.w.p" => "string"
      })
    end

    it "uses the first and last parameters" do
      expect {
        I18nContent.flat_hash("string", nil, "not hash")
      }.to raise_error(NoMethodError)

      expect(I18nContent.flat_hash(nil, nil, { q: "other string" })).to eq({
        q: "other string",
        nil => nil
      })

      expect(I18nContent.flat_hash({ w: "string" }, nil, { q: "other string" })).to eq({
        q: "other string",
        "w" => "string"
      })

      expect(I18nContent.flat_hash({w: { p: "string" } }, nil, { q: "other string" })).to eq({
        q: "other string",
        "w.p" => "string"
      })
    end

    it "uses all parameters" do
      expect {
        I18nContent.flat_hash("string", "f", "not hash")
      }.to raise_error NoMethodError

      expect(I18nContent.flat_hash(nil, "f", { q: "other string" })).to eq({
        q: "other string",
        "f" => nil
      })

      expect(I18nContent.flat_hash({ w: "string" }, "f", { q: "other string" })).to eq({
        q: "other string",
        "f.w" => "string"
      })

      expect(I18nContent.flat_hash({ w: { p: "string" } }, "f", { q: "other string" })).to eq({
        q: "other string",
        "f.w.p" => "string"
      })
    end
  end
end
