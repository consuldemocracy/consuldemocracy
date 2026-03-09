require "rails_helper"

describe ImageSuggestions::Pexels do
  let(:pexels_client) { instance_double(::Pexels::Client) }
  let(:photos_client) { instance_double(::Pexels::Client::Photos) }

  describe "evaluates provider configuration across different tenants" do
    before do
      stub_secrets(
        pexels_access_key: "test_key",
        tenants: {
          new_tenant_name: {
            pexels_access_key: "new_tenant_pexels_access_key"
          }
        }
      )
    end

    it "uses the pexels access key for the current tenant" do
      allow(Tenant).to receive(:current_schema).and_return("new_tenant_name")
      expect(::Pexels::Client).to receive(:new).with("new_tenant_pexels_access_key").and_return(pexels_client)
      ImageSuggestions::Pexels.new
    end
  end

  describe "#search" do
    let(:pexels_instance) { ImageSuggestions::Pexels.new }
    let(:search_results) { instance_double(::Pexels::PhotoSet) }

    before do
      allow(::Pexels::Client).to receive(:new).and_return(pexels_client)
      allow(pexels_client).to receive(:photos).and_return(photos_client)
    end

    it "returns search results from Pexels API" do
      expect(photos_client).to receive(:search).with("test query", per_page: 10).and_return(search_results)

      result = pexels_instance.search("test query", per_page: 10)

      expect(result).to eq(search_results)
    end
  end

  describe "#download" do
    let(:pexels_instance) { ImageSuggestions::Pexels.new }
    let(:photo_id) { "12345" }

    let(:photo) do
      instance_double(
        ::Pexels::Photo,
        src: { "original" => "https://example.com/image.jpg" },
        user: instance_double(::Pexels::User, name: "John Doe")
      )
    end

    let(:image_url) { "https://example.com/image.jpg?auto=compress&cs=tinysrgb&h=900" }
    let(:downloaded_io) { StringIO.new("fake image bytes") }
    let(:uri_double) { double("URI") }

    before do
      allow(::Pexels::Client).to receive(:new).and_return(pexels_client)
      allow(pexels_client).to receive(:photos).and_return(photos_client)
      allow(photos_client).to receive(:find).with(photo_id).and_return(photo)
      allow(URI).to receive(:parse).with(image_url).and_return(uri_double)
      allow(uri_double).to receive(:open).with("rb").and_return(downloaded_io)
    end

    it "returns an UploadedFile with jpeg content_type and filename from I18n" do
      result = pexels_instance.download(photo_id)

      expect(result).to be_a ActionDispatch::Http::UploadedFile
      expect(result.content_type).to eq "image/jpeg"
      expect(result.original_filename).to eq "Image by John Doe.jpg"
    end

    context "when photo is not found" do
      before do
        allow(photos_client).to receive(:find).with(photo_id)
                                              .and_raise(::Pexels::APIError.new("Photo not found"))
      end

      it "raises Pexels::APIError" do
        expect do
          pexels_instance.download(photo_id)
        end.to raise_error(::Pexels::APIError, "Photo not found")
      end
    end

    context "when HTTP response is not successful" do
      before do
        allow(uri_double).to receive(:open).with("rb")
                                           .and_raise(OpenURI::HTTPError.new("404 Not Found", nil))
      end

      it "raises PexelsError" do
        expect do
          pexels_instance.download(photo_id)
        end.to raise_error(ImageSuggestions::Pexels::PexelsError, /Failed to download image from Pexels:/)
      end
    end

    context "when network error occurs" do
      before do
        allow(uri_double).to receive(:open).with("rb")
                                           .and_raise(SocketError.new("Connection refused"))
      end

      it "raises PexelsError" do
        expect do
          pexels_instance.download(photo_id)
        end.to raise_error(ImageSuggestions::Pexels::PexelsError, /Failed to download image from Pexels:/)
      end
    end
  end
end
