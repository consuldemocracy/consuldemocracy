require "rails_helper"

describe RemoteTranslation, :remote_translations do
  let(:remote_translation) { build(:remote_translation, locale: :es) }

  it "is valid" do
    expect(remote_translation).to be_valid
  end

  it "is valid without error_message" do
    remote_translation.error_message = nil
    expect(remote_translation).to be_valid
  end

  it "is not valid without to" do
    remote_translation.locale = nil
    expect(remote_translation).not_to be_valid
  end

  it "is not valid without a remote_translatable_id" do
    remote_translation.remote_translatable_id = nil
    expect(remote_translation).not_to be_valid
  end

  it "is not valid without a remote_translatable_type" do
    remote_translation.remote_translatable_type = nil
    expect(remote_translation).not_to be_valid
  end

  it "is not valid without an available_locales" do
    remote_translation.locale = "unavailable_locale"
    expect(remote_translation).not_to be_valid
  end

  it "is not valid when exists a translation for locale" do
    remote_translation.locale = :en
    expect(remote_translation).not_to be_valid
  end

  it "checks available locales dynamically" do
    allow(RemoteTranslation).to receive(:available_locales).and_return(["en"])

    expect(remote_translation).not_to be_valid

    allow(RemoteTranslation).to receive(:available_locales).and_return(["es"])

    expect(remote_translation).to be_valid
  end

  describe ".available_locales" do
    it "returns I18n.available_locales as strings" do
      allow(I18n).to receive(:available_locales).and_return([:en, :es, :fr])

      expect(RemoteTranslation.available_locales).to eq(%w[en es fr])
    end
  end

  describe ".configured?" do
    it "is true when all LLM settings are present" do
      Setting["llm.provider"] = "OpenAI"
      Setting["llm.model"] = "gpt-4o-mini"
      Setting["llm.use_llm_for_translations"] = true

      expect(RemoteTranslation.configured?).to be true
    end

    it "is false when any LLM setting is missing" do
      Setting["llm.provider"] = "OpenAI"
      Setting["llm.model"] = nil
      Setting["llm.use_llm_for_translations"] = true

      expect(RemoteTranslation.configured?).to be false
    end
  end

  describe "#enqueue_remote_translation" do
    it "after create enqueue Delayed Job", :delay_jobs do
      expect { remote_translation.save }.to change { Delayed::Job.count }.by(1)
    end

    it "enqueues the job after committing the transaction", :delay_jobs do
      ActiveRecord::Base.transaction do
        remote_translation.save!
        expect(Delayed::Job.count).to eq 0
      end

      expect(Delayed::Job.count).to eq 1
    end
  end

  describe "#translate_remotely!" do
    let(:client) { RemoteTranslations::Client }

    context "Debates" do
      let(:debate) { create(:debate) }

      it "returns the resource with new translation persisted" do
        response = ["Título traducido", "Descripción traducida"]
        expect_any_instance_of(client).to receive(:call).and_return(response)

        create(:remote_translation, remote_translatable: debate, locale: :es)

        expect(debate.translations.count).to eq(2)
      end

      it "when new translation locale is distinct to default_locale skip length validations" do
        response = ["TT", "Descripción traducida"]
        expect_any_instance_of(client).to receive(:call).and_return(response)

        remote_translation = create(:remote_translation, remote_translatable: debate, locale: :es)

        expect(remote_translation.error_message).to be nil
        expect(debate.translations.count).to eq(2)
        expect(debate.valid?).to be true
      end

      it "when new translation locale is distinct to default_locale not skip presence validations" do
        response = ["", "Descripción traducida"]
        expect_any_instance_of(client).to receive(:call).and_return(response)

        remote_translation = create(:remote_translation, remote_translatable: debate, locale: :es)

        expect(remote_translation.error_message).to include("can't be blank")
        expect(debate.translations.count).to eq(1)
        expect(debate.valid?).to be false
      end

      it "destroy remote translation instance" do
        response = ["Título traducido", "Descripción traducida"]
        expect_any_instance_of(client).to receive(:call).and_return(response)

        create(:remote_translation, remote_translatable: debate, locale: :es)

        expect(RemoteTranslation.count).to eq(0)
      end
    end

    context "Proposals" do
      let!(:proposal) { create(:proposal) }

      it "returns the resource with new translation persisted" do
        response = ["Título traducido", "Descripción traducida", "Pregunta traducida",
                    "Resumen traducido", nil]
        expect_any_instance_of(client).to receive(:call).and_return(response)

        create(:remote_translation, remote_translatable: proposal, locale: :es)

        expect(proposal.translations.count).to eq(2)
      end

      it "when new translation locale is distinct to default_locale skip lenght validations" do
        response = ["TT", "Descripción traducida", "Pregunta traducida", "Resumen traducido", nil]
        expect_any_instance_of(client).to receive(:call).and_return(response)

        remote_translation = create(:remote_translation, remote_translatable: proposal, locale: :es)

        expect(remote_translation.error_message).to be nil
        expect(proposal.translations.count).to eq(2)
        expect(proposal.valid?).to be true
      end

      it "when new translation locale is distinct to default_locale do not skip presence validations" do
        response = ["", "Descripción traducida", "Pregunta traducida", "Resumen traducido", nil]
        expect_any_instance_of(client).to receive(:call).and_return(response)

        remote_translation = create(:remote_translation, remote_translatable: proposal, locale: :es)

        expect(remote_translation.error_message).to include("can't be blank")
        expect(proposal.translations.count).to eq(1)
        expect(proposal.valid?).to be false
      end

      it "destroy remote translation instance" do
        response = ["Título traducido", "Descripción traducida", "Pregunta traducida",
                    "Resumen traducido", nil]
        expect_any_instance_of(client).to receive(:call).and_return(response)

        create(:remote_translation, remote_translatable: proposal, locale: :es)

        expect(RemoteTranslation.count).to eq(0)
      end
    end

    context "Budget Investments" do
      let(:budget_investment) { create(:budget_investment) }

      it "returns the resource with new translation persisted" do
        response = ["Título traducido", "Descripción traducida"]
        expect_any_instance_of(client).to receive(:call).and_return(response)

        create(:remote_translation, remote_translatable: budget_investment, locale: :es)

        expect(budget_investment.translations.count).to eq(2)
      end

      it "when new translation locale is distinct to default_locale skip lenght validations" do
        response = ["TT", "Descripción traducida"]
        expect_any_instance_of(client).to receive(:call).and_return(response)

        remote_translation = create(:remote_translation, remote_translatable: budget_investment, locale: :es)

        expect(remote_translation.error_message).to be nil
        expect(budget_investment.translations.count).to eq(2)
        expect(budget_investment.valid?).to be true
      end

      it "when new translation locale is distinct to default_locale not skip presence validations" do
        response = ["", "Descripción traducida"]
        expect_any_instance_of(client).to receive(:call).and_return(response)

        remote_translation = create(:remote_translation, remote_translatable: budget_investment, locale: :es)

        expect(remote_translation.error_message).to include("can't be blank")
        expect(budget_investment.translations.count).to eq(1)
        expect(budget_investment.valid?).to be false
      end

      it "destroy remote translation instance" do
        response = ["Título traducido", "Descripción traducida"]
        expect_any_instance_of(client).to receive(:call).and_return(response)

        create(:remote_translation, remote_translatable: budget_investment, locale: :es)

        expect(RemoteTranslation.count).to eq(0)
      end
    end

    context "Comments" do
      let(:comment) { create(:comment) }

      it "returns the resource with new translation persisted" do
        response = ["Body traducido"]
        expect_any_instance_of(client).to receive(:call).and_return(response)

        create(:remote_translation, remote_translatable: comment, locale: :es)

        expect(comment.translations.count).to eq(2)
      end

      it "when new translation locale is distinct to default_locale skip lenght validations" do
        response = ["BT"]
        expect_any_instance_of(client).to receive(:call).and_return(response)

        remote_translation = create(:remote_translation, remote_translatable: comment, locale: :es)

        expect(remote_translation.error_message).to be nil
        expect(comment.translations.count).to eq(2)
        expect(comment.valid?).to be true
      end

      it "when new translation locale is distinct to default_locale not skip presence validations" do
        response = [""]
        expect_any_instance_of(client).to receive(:call).and_return(response)

        remote_translation = create(:remote_translation, remote_translatable: comment, locale: :es)

        expect(remote_translation.error_message).to include("can't be blank")
        expect(comment.translations.count).to eq(1)
        expect(comment.valid?).to be false
      end

      it "destroy remote translation instance" do
        response = ["Body traducido"]
        expect_any_instance_of(client).to receive(:call).and_return(response)

        create(:remote_translation, remote_translatable: comment, locale: :es)

        expect(RemoteTranslation.count).to eq(0)
      end
    end

    describe "#fields_values" do
      let!(:proposal) { create(:proposal, description: "&Sigma; with sample text") }

      it "sanitizes field values when they contain entity references such as &Sigma;" do
        field_values_sanitized = [proposal.title, "Σ with sample text", proposal.summary,
                                  proposal.retired_reason]
        fake_response = ["translated title", "translated description", "translated summary", nil]

        expect_any_instance_of(client).to receive(:call).with(field_values_sanitized, "es")
                                                        .and_return(fake_response)

        create(:remote_translation, remote_translatable: proposal, locale: :es)
      end
    end
  end
end
