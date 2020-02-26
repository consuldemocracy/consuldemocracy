require "rails_helper"

describe Rack::Attack, type: :request do
  before do
    RemoteTranslation.skip_callback(:create, :after, :enqueue_remote_translation)
  end

  after do
    RemoteTranslation.set_callback(:create, :after, :enqueue_remote_translation)
    Rails.cache.clear
  end

  it "throttle requests/ip is defined" do
    expect(Rack::Attack.throttles.key?("requests/ip")).to eq true
  end

  describe "throttle excessive requests by IP address" do
    context "when number of requests is higher than the limit" do
      it "and request path is not /remote_translations the status response is success" do
        600.times do
          Rack::Attack.cache.count("requests/ip:1.2.3.4", 60)
        end
        get "/", headers: { REMOTE_ADDR: "1.2.3.4" }

        expect(response).not_to have_http_status(:too_many_requests)
        expect(response).to have_http_status(:success)
      end

      it "changes the request status to 429" do
        600.times do
          Rack::Attack.cache.count("requests/ip:1.2.3.4", 60)
        end
        debate = create(:debate)
        remote_translations_params = [{ remote_translatable_id: debate.id.to_s,
                                        remote_translatable_type: debate.class.to_s,
                                        locale: :es }].to_json
        post "/remote_translations", params: { remote_translations: remote_translations_params },
                                     headers: { REMOTE_ADDR: "1.2.3.4", HTTP_REFERER: "any_path" }
        expect(response).to have_http_status(:too_many_requests)
      end
    end
  end
end
