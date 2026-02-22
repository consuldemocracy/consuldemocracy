require "open-uri"

module ImageSuggestions
  class Pexels
    class PexelsError < StandardError; end
    IMAGE_VARIANT_POSTFIX = "?auto=compress&cs=tinysrgb&h=900".freeze

    def self.search(query, **)
      new.search(query, **)
    end

    def self.download(photo_id)
      new.download(photo_id)
    end

    def initialize
      @client = ::Pexels::Client.new(Tenant.current_secrets.pexels_access_key)
    end

    def search(query, **)
      @client.photos.search(query, **)
    end

    def download(photo_id)
      photo = get_photo(photo_id)

      image_url = photo.src["original"] + IMAGE_VARIANT_POSTFIX
      temp_file = download_file(image_url)

      ActionDispatch::Http::UploadedFile.new(
        tempfile: temp_file,
        filename: I18n.t("images.form.suggested_image_filename", author_name: photo.user.name),
        type: "image/jpeg"
      )
    end

    private

      def get_photo(photo_id)
        @client.photos.find(photo_id)
      end

      def download_file(image_url)
        URI.parse(image_url).open("rb")
      rescue OpenURI::HTTPError, SocketError => e
        raise PexelsError, "Failed to download image from Pexels: #{e.message}"
      end
  end
end
