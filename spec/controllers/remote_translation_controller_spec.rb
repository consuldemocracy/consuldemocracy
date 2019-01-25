require 'rails_helper'

describe RemoteTranslationsController do

  describe 'POST create' do
    before do
      @debate = create(:debate)
      @remote_translations_params = [{ remote_translatable_id: @debate.id.to_s,
                                      remote_translatable_type: @debate.class.to_s,
                                      locale: :es }].to_json
      allow(controller.request).to receive(:referer).and_return('any_path')
      Delayed::Worker.delay_jobs = true
    end

    after do
      Delayed::Worker.delay_jobs = false
    end

    it 'set_remote_translations parse correctly remote_translations_params' do
      post :create, remote_translations: @remote_translations_params

      expect(assigns(:remote_translations).count).to eq(1)
    end

    it 'create correctly remote translation' do
      post :create, remote_translations: @remote_translations_params

      expect(RemoteTranslation.count).to eq(1)
    end

    it 'create remote translation when same remote translation with error_message is enqueued' do
      create(:remote_translation, remote_translatable: @debate, locale: :es, error_message: "Has errors")

      post :create, remote_translations: @remote_translations_params

      expect(RemoteTranslation.count).to eq(2)
    end

    it 'not create remote translation when same remote translation is enqueued' do
      create(:remote_translation, remote_translatable: @debate, locale: :es)

      post :create, remote_translations: @remote_translations_params

      expect(RemoteTranslation.count).to eq(1)
    end

    it 'redirect_to request referer after create' do
      post :create, remote_translations: @remote_translations_params

      expect(subject).to redirect_to('any_path')
    end

  end
end
