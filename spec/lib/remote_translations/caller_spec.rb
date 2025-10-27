require "rails_helper"

describe RemoteTranslations::Caller, :remote_translations do
  before do
    RemoteTranslation.skip_callback(:create, :after, :enqueue_remote_translation)
  end

  after do
    RemoteTranslation.set_callback(:create, :after, :enqueue_remote_translation)
  end

  let(:client) { RemoteTranslations::Microsoft::Client }

  describe "#call" do
    context "Debates" do
      let(:debate)             { create(:debate) }
      let(:remote_translation) do
        create(:remote_translation, remote_translatable: debate, locale: :es)
      end
      let(:caller) { RemoteTranslations::Caller.new(remote_translation) }

      it "returns the resource with new translation persisted" do
        response = ["Título traducido", "Descripción traducida"]
        expect_any_instance_of(client).to receive(:call).and_return(response)

        caller.call

        expect(debate.translations.count).to eq(2)
      end

      it "when new translation locale is distinct to default_locale skip length validations" do
        response = ["TT", "Descripción traducida"]
        expect_any_instance_of(client).to receive(:call).and_return(response)

        caller.call

        expect(remote_translation.error_message).to be nil
        expect(debate.translations.count).to eq(2)
        expect(debate.valid?).to be true
      end

      it "when new translation locale is distinct to default_locale not skip presence validations" do
        response = ["", "Descripción traducida"]
        expect_any_instance_of(client).to receive(:call).and_return(response)

        caller.call

        expect(remote_translation.error_message).to include("can't be blank")
        expect(debate.translations.count).to eq(1)
        expect(debate.valid?).to be false
      end

      it "destroy remote translation instance" do
        response = ["Título traducido", "Descripción traducida"]
        expect_any_instance_of(client).to receive(:call).and_return(response)

        caller.call

        expect(RemoteTranslation.count).to eq(0)
      end
    end

    context "Proposals" do
      let!(:proposal)          { create(:proposal) }
      let(:remote_translation) do
        create(:remote_translation, remote_translatable: proposal, locale: :es)
      end
      let(:caller) { RemoteTranslations::Caller.new(remote_translation) }

      it "returns the resource with new translation persisted" do
        response = ["Título traducido", "Descripción traducida", "Pregunta traducida",
                    "Resumen traducido", nil]
        expect_any_instance_of(client).to receive(:call).and_return(response)

        caller.call

        expect(proposal.translations.count).to eq(2)
      end

      it "when new translation locale is distinct to default_locale skip lenght validations" do
        response = ["TT", "Descripción traducida", "Pregunta traducida", "Resumen traducido", nil]
        expect_any_instance_of(client).to receive(:call).and_return(response)

        caller.call

        expect(remote_translation.error_message).to be nil
        expect(proposal.translations.count).to eq(2)
        expect(proposal.valid?).to be true
      end

      it "when new translation locale is distinct to default_locale do not skip presence validations" do
        response = ["", "Descripción traducida", "Pregunta traducida", "Resumen traducido", nil]
        expect_any_instance_of(client).to receive(:call).and_return(response)

        caller.call

        expect(remote_translation.error_message).to include("can't be blank")
        expect(proposal.translations.count).to eq(1)
        expect(proposal.valid?).to be false
      end

      it "destroy remote translation instance" do
        response = ["Título traducido", "Descripción traducida", "Pregunta traducida",
                    "Resumen traducido", nil]
        expect_any_instance_of(client).to receive(:call).and_return(response)

        caller.call

        expect(RemoteTranslation.count).to eq(0)
      end
    end

    context "Budget Investments" do
      let(:budget_investment)  { create(:budget_investment) }
      let(:remote_translation) do
        create(:remote_translation, remote_translatable: budget_investment, locale: :es)
      end
      let(:caller) { RemoteTranslations::Caller.new(remote_translation) }

      it "returns the resource with new translation persisted" do
        response = ["Título traducido", "Descripción traducida"]
        expect_any_instance_of(client).to receive(:call).and_return(response)

        caller.call

        expect(budget_investment.translations.count).to eq(2)
      end

      it "when new translation locale is distinct to default_locale skip lenght validations" do
        response = ["TT", "Descripción traducida"]
        expect_any_instance_of(client).to receive(:call).and_return(response)

        caller.call

        expect(remote_translation.error_message).to be nil
        expect(budget_investment.translations.count).to eq(2)
        expect(budget_investment.valid?).to be true
      end

      it "when new translation locale is distinct to default_locale not skip presence validations" do
        response = ["", "Descripción traducida"]
        expect_any_instance_of(client).to receive(:call).and_return(response)

        caller.call

        expect(remote_translation.error_message).to include("can't be blank")
        expect(budget_investment.translations.count).to eq(1)
        expect(budget_investment.valid?).to be false
      end

      it "destroy remote translation instance" do
        response = ["Título traducido", "Descripción traducida"]
        expect_any_instance_of(client).to receive(:call).and_return(response)

        caller.call

        expect(RemoteTranslation.count).to eq(0)
      end
    end

    context "Comments" do
      let(:comment)            { create(:comment) }
      let(:remote_translation) do
        create(:remote_translation, remote_translatable: comment, locale: :es)
      end
      let(:caller) { RemoteTranslations::Caller.new(remote_translation) }

      it "returns the resource with new translation persisted" do
        response = ["Body traducido"]
        expect_any_instance_of(client).to receive(:call).and_return(response)

        caller.call

        expect(comment.translations.count).to eq(2)
      end

      it "when new translation locale is distinct to default_locale skip lenght validations" do
        response = ["BT"]
        expect_any_instance_of(client).to receive(:call).and_return(response)

        caller.call

        expect(remote_translation.error_message).to be nil
        expect(comment.translations.count).to eq(2)
        expect(comment.valid?).to be true
      end

      it "when new translation locale is distinct to default_locale not skip presence validations" do
        response = [""]
        expect_any_instance_of(client).to receive(:call).and_return(response)

        caller.call

        expect(remote_translation.error_message).to include("can't be blank")
        expect(comment.translations.count).to eq(1)
        expect(comment.valid?).to be false
      end

      it "destroy remote translation instance" do
        response = ["Body traducido"]
        expect_any_instance_of(client).to receive(:call).and_return(response)

        caller.call

        expect(RemoteTranslation.count).to eq(0)
      end
    end
  end

  describe "#field values" do
    let!(:proposal)          { create(:proposal, description: "&Sigma; with sample text") }
    let(:remote_translation) do
      create(:remote_translation, remote_translatable: proposal, locale: :es)
    end
    let(:caller) { RemoteTranslations::Caller.new(remote_translation) }

    it "sanitize field value when the field contains entity references as &Sigma;" do
      field_values_sanitized = [proposal.title, "Σ with sample text", proposal.summary,
                                proposal.retired_reason]
      locale = remote_translation.locale
      fake_response = ["translated title", "translated description", "translated summary", nil]

      expect_any_instance_of(client).to receive(:call).with(field_values_sanitized, locale)
                                                      .and_return(fake_response)

      caller.call
    end
  end

  describe ".configured?" do
    it "is true if llm? is true regardless of microsoft key" do
      allow(RemoteTranslations::Caller).to receive(:llm?).and_return(true)
      allow(Tenant).to receive_message_chain(:current_secrets, :microsoft_api_key).and_return(nil)

      expect(RemoteTranslations::Caller.configured?).to be true
    end

    it "falls back to microsoft settings when llm? is false" do
      allow(RemoteTranslations::Caller).to receive(:llm?).and_return(false)
      Setting["feature.remote_translations"] = true
      allow(Tenant).to receive_message_chain(:current_secrets, :microsoft_api_key).and_return("key")

      expect(RemoteTranslations::Caller.configured?).to be true
    end
  end

  describe ".llm?" do
    it "is true when all LLM settings are present" do
      Setting["llm.provider"] = "OpenAI"
      Setting["llm.model"] = "gpt-4o-mini"
      Setting["llm.use_llm_for_translations"] = true

      expect(RemoteTranslations::Caller.llm?).to be true
    end

    it "is false when any LLM setting is missing" do
      Setting["llm.provider"] = "OpenAI"
      Setting["llm.model"] = nil
      Setting["llm.use_llm_for_translations"] = true

      expect(RemoteTranslations::Caller.llm?).to be false
    end
  end

  describe ".translation_provider" do
    it "returns Microsoft by default" do
      expect(RemoteTranslations::Caller.translation_provider).to eq(RemoteTranslations::Microsoft)
    end

    it "returns Llm when llm? is true" do
      allow(RemoteTranslations::Caller).to receive(:llm?).and_return(true)

      expect(RemoteTranslations::Caller.translation_provider).to eq(RemoteTranslations::Llm)
    end
  end

  describe ".available_locales" do
    it "returns Microsoft by default" do
      expect(RemoteTranslations::Caller.available_locales).to eq(
        RemoteTranslations::Microsoft::AvailableLocales.locales
      )
    end

    it "returns Llm when llm? is true" do
      allow(RemoteTranslations::Caller).to receive(:llm?).and_return(true)

      expect(RemoteTranslations::Caller.available_locales).to eq(
        RemoteTranslations::Llm::AvailableLocales.locales
      )
    end
  end
end
