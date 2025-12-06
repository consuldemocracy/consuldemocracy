require "rails_helper"

describe ImageSuggestions::Pexels do
  let(:pexels_client) { instance_double(::Pexels::Client) }
  let(:photos_client) { instance_double(::Pexels::Client::Photos) }
  let(:pexels_instance) { ImageSuggestions::Pexels.new }
  let(:photo_id) { "12345" }
  let(:photo) do
    instance_double(
      ::Pexels::Photo,
      id: photo_id,
      src: { "original" => "https://example.com/image.jpg" },
      user: instance_double(::Pexels::User, name: "John Doe")
    )
  end

  before do
    allow(::Pexels::Client).to receive(:new).and_return(pexels_client)
    allow(pexels_client).to receive(:photos).and_return(photos_client)
    stub_secrets(pexels_access_key: "test_key")
  end

  describe "evaluates provider configuration across different tenants" do
    before do
      stub_secrets(
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

  describe ".search" do
    let(:search_results) { instance_double(::Pexels::PhotoSet, photos: [photo]) }

    it "delegates to instance search method" do
      expect_any_instance_of(ImageSuggestions::Pexels).to receive(:search).with("test query", per_page: 10)
      ImageSuggestions::Pexels.search("test query", per_page: 10)
    end

    it "returns search results from Pexels API" do
      allow(photos_client).to receive(:search).with("test query", per_page: 10).and_return(search_results)
      result = pexels_instance.search("test query", per_page: 10)
      expect(result).to eq(search_results)
    end
  end

  describe ".download" do
    it "delegates to instance download method" do
      expect_any_instance_of(ImageSuggestions::Pexels).to receive(:download).with(photo_id)
      ImageSuggestions::Pexels.download(photo_id)
    end
  end

  describe "#download" do
    let(:uri) { URI("https://example.com/image.jpg?auto=compress&cs=tinysrgb&h=900") }
    let(:http_response) { instance_double(Net::HTTPSuccess, is_a?: true, read_body: nil, code: "200") }
    let(:temp_file) { instance_double(Tempfile, write: nil, rewind: nil, close!: nil) }
    let(:http_client) { double("http_client") }

    before do
      allow(photos_client).to receive(:find).with(photo_id).and_return(photo)
      allow(Tempfile).to receive(:new).and_return(temp_file)
      allow(Net::HTTP).to receive(:start).and_yield(http_client).and_return(temp_file)
      allow(http_client).to receive(:request).with(instance_of(Net::HTTP::Get)).and_yield(http_response).and_return(temp_file)
      allow(http_response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(true)
      allow(http_response).to receive(:read_body).and_yield("image data")
      allow(temp_file).to receive(:path).and_return("/tmp/test")
      allow(temp_file).to receive_messages(path: "/tmp/test", is_a?: true)
    end

    it "downloads the image and returns an UploadedFile" do
      allow(temp_file).to receive(:is_a?).and_return(false)
      allow(ActionDispatch::Http::UploadedFile).to receive(:new).and_call_original

      result = pexels_instance.download(photo_id)

      expect(result).to be_a(ActionDispatch::Http::UploadedFile)
    end

    it "uses the photo's original URL with variant parameters" do
      expect(URI).to receive(:parse).with(
        "https://example.com/image.jpg?auto=compress&cs=tinysrgb&h=900"
      ).and_return(uri)

      pexels_instance.download(photo_id)
    end

    it "sets filename with author name from translation" do
      allow(temp_file).to receive(:is_a?).and_return(false)
      expect(I18n).to receive(:t).with(
        "images.form.suggested_image_filename",
        author_name: "John Doe"
      ).and_return("Image by John Doe.jpg")

      pexels_instance.download(photo_id)
    end

    context "when photo is not found" do
      before do
        allow(photos_client).to receive(:find).with(photo_id)
                                              .and_raise(::Pexels::APIError.new("Photo not found"))
      end

      it "raises PexelsError" do
        expect do
          pexels_instance.download(photo_id)
        end.to raise_error(::Pexels::APIError, "Photo not found")
      end
    end

    context "when HTTP response is not successful" do
      let(:http_error_response) { instance_double(Net::HTTPResponse, code: "404", is_a?: false) }
      let(:http_client_error) { double("http_client") }

      before do
        allow(Net::HTTP).to receive(:start).and_yield(http_client_error)
        allow(http_client_error).to receive(:request).with(instance_of(Net::HTTP::Get)).and_yield(http_error_response)
        allow(http_error_response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(false)
        allow(http_error_response).to receive(:read_body).and_yield("error body")
      end

      it "raises PexelsError" do
        expect do
          pexels_instance.download(photo_id)
        end.to raise_error(ImageSuggestions::Pexels::PexelsError, /Failed to download image/)
      end
    end
  end
end
