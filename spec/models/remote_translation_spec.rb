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
    allow(RemoteTranslations::Microsoft::AvailableLocales)
      .to receive(:locales).and_return(["en"])

    expect(remote_translation).not_to be_valid

    allow(RemoteTranslations::Microsoft::AvailableLocales)
      .to receive(:locales).and_return(["es"])

    expect(remote_translation).to be_valid
  end

  it "is valid with a locale that uses a different name in the remote service" do
    allow(RemoteTranslations::Microsoft::AvailableLocales).to receive(:locales).and_call_original
    allow(RemoteTranslations::Microsoft::AvailableLocales).to receive(:remote_available_locales)
                                                          .and_return(["pt"])

    remote_translation.locale = :"pt-BR"

    expect(remote_translation).to be_valid
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

    it "uses the same remote translations caller and client every time" do
      client_class = RemoteTranslations::Microsoft::Client

      expect_any_instance_of(client_class).to receive(:call).and_return([])

      remote_translation.enqueue_remote_translation
      remote_translation.enqueue_remote_translation
    end
  end

  describe ".for" do
    it "detects remote translations when collections and featured_proposals are not translated" do
      proposals = create_list(:proposal, 3)
      featured_proposals = create_featured_proposals

      I18n.with_locale(:es) do
        expect(RemoteTranslation.for(proposals, featured_proposals).count).to eq 6
      end
    end

    it "detects remote translations with nil as argument when collections are not translated" do
      proposals = create_list(:proposal, 3)

      I18n.with_locale(:es) do
        expect(RemoteTranslation.for(proposals, nil).count).to eq 3
      end
    end

    it "detects remote translations with [] as argument when collections are not translated" do
      proposals = create_list(:proposal, 3)

      I18n.with_locale(:es) do
        expect(RemoteTranslation.for(proposals, []).count).to eq 3
      end
    end

    it "detects remote translations when widget feeds are not translated" do
      create_list(:proposal, 3)
      create_list(:debate, 3)
      create_list(:legislation_process, 3)
      create(:widget_feed, kind: "proposals")
      create(:widget_feed, kind: "debates")
      create(:widget_feed, kind: "processes")
      widget_feeds = Widget::Feed.active

      I18n.with_locale(:es) do
        expect(RemoteTranslation.for(widget_feeds).count).to eq 9
      end
    end
  end
end
