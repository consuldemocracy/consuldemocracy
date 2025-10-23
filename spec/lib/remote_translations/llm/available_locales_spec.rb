require "rails_helper"

describe RemoteTranslations::Llm::AvailableLocales do
  it "returns all I18n.available_locales as strings" do
    allow(I18n).to receive(:available_locales).and_return([:en, :es, :fr])

    expect(RemoteTranslations::Llm::AvailableLocales.locales).to eq(%w[en es fr])
  end
end
