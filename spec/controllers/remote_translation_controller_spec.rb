require "rails_helper"

describe RemoteTranslationsController do

  describe "POST create" do
    let(:debate)             { create(:debate) }

    before do
      @remote_translations_params = [{ remote_translatable_id: debate.id.to_s,
                                       remote_translatable_type: debate.class.to_s,
                                       locale: :es }].to_json
      request.env["HTTP_REFERER"] = "any_path"
      Delayed::Worker.delay_jobs = true
    end

    after do
      Delayed::Worker.delay_jobs = false
    end

    it "create correctly remote translation" do
      post :create, params: { remote_translations: @remote_translations_params }

      expect(RemoteTranslation.count).to eq(1)
    end

    it "create remote translation when same remote translation with error_message is enqueued" do
      create(:remote_translation, remote_translatable: debate, locale: :es, error_message: "Has errors")

      post :create, params: { remote_translations: @remote_translations_params }

      expect(RemoteTranslation.count).to eq(2)
    end

    it "not create remote translation when same remote translation is enqueued" do
      create(:remote_translation, remote_translatable: debate, locale: :es)

      post :create, params: { remote_translations: @remote_translations_params }

      expect(RemoteTranslation.count).to eq(1)
    end

    it "redirect_to request referer after create" do
      post :create, params: { remote_translations: @remote_translations_params }

      expect(subject).to redirect_to("any_path")
    end

  end
end
