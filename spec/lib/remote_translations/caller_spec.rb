require "rails_helper"

describe RemoteTranslations::Caller do

  before do
    RemoteTranslation.skip_callback(:create, :after, :enqueue_remote_translation)
  end

  after do
    RemoteTranslation.set_callback(:create, :after, :enqueue_remote_translation)
  end

  describe "#call" do

    let(:client) { RemoteTranslations::Microsoft::Client }

    context "Debates" do

      let(:debate)             { create(:debate) }
      let(:remote_translation) { create(:remote_translation,
                                        remote_translatable: debate, locale: :es) }
      let(:caller) { described_class.new(remote_translation) }

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

        expect(remote_translation.error_message).to eq nil
        expect(debate.translations.count).to eq(2)
        expect(debate.valid?).to eq true
      end

      it "when new translation locale is distinct to default_locale not skip presence validations" do
        response = ["", "Descripción traducida"]
        expect_any_instance_of(client).to receive(:call).and_return(response)

        caller.call

        expect(remote_translation.error_message).to include("can't be blank")
        expect(debate.translations.count).to eq(1)
        expect(debate.valid?).to eq false
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
      let(:remote_translation) { create(:remote_translation,
                                        remote_translatable: proposal, locale: :es) }
      let(:caller) { described_class.new(remote_translation) }

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

        expect(remote_translation.error_message).to eq nil
        expect(proposal.translations.count).to eq(2)
        expect(proposal.valid?).to eq true
      end

      it "when new translation locale is distinct to default_locale do not skip presence validations" do
        response = ["", "Descripción traducida", "Pregunta traducida", "Resumen traducido", nil]
        expect_any_instance_of(client).to receive(:call).and_return(response)

        caller.call

        expect(remote_translation.error_message).to include("can't be blank")
        expect(proposal.translations.count).to eq(1)
        expect(proposal.valid?).to eq false
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
      let(:remote_translation) { create(:remote_translation,
                                        remote_translatable: budget_investment,
                                        locale: :es) }
      let(:caller) { described_class.new(remote_translation) }

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

        expect(remote_translation.error_message).to eq nil
        expect(budget_investment.translations.count).to eq(2)
        expect(budget_investment.valid?).to eq true
      end

      it "when new translation locale is distinct to default_locale not skip presence validations" do
        response = ["", "Descripción traducida"]
        expect_any_instance_of(client).to receive(:call).and_return(response)

        caller.call

        expect(remote_translation.error_message).to include("can't be blank")
        expect(budget_investment.translations.count).to eq(1)
        expect(budget_investment.valid?).to eq false
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
      let(:remote_translation) { create(:remote_translation,
                                        remote_translatable: comment, locale: :es) }
      let(:caller) { described_class.new(remote_translation) }

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

        expect(remote_translation.error_message).to eq nil
        expect(comment.translations.count).to eq(2)
        expect(comment.valid?).to eq true
      end

      it "when new translation locale is distinct to default_locale not skip presence validations" do
        response = [""]
        expect_any_instance_of(client).to receive(:call).and_return(response)

        caller.call

        expect(remote_translation.error_message).to include("can't be blank")
        expect(comment.translations.count).to eq(1)
        expect(comment.valid?).to eq false
      end

      it "destroy remote translation instance" do
        response = ["Body traducido"]
        expect_any_instance_of(client).to receive(:call).and_return(response)

        caller.call

        expect(RemoteTranslation.count).to eq(0)
      end
    end

  end

end
