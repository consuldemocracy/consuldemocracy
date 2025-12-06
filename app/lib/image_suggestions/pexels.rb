module ImageSuggestions
  class Pexels
    class PexelsError < StandardError; end
    IMAGE_VARIANT_POSTFIX = "?auto=compress&cs=tinysrgb&h=900".freeze
    attr_reader :photo

    # returns a search response from Pexels
    def self.search(query, **)
      new.search(query, **)
    end

    # returns an ActionDispatch::Http::UploadedFile of the image from Pexels
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

      uri = URI(photo.src["original"] + IMAGE_VARIANT_POSTFIX)
      temp_file = download_file(uri)

      ActionDispatch::Http::UploadedFile.new(
        tempfile: temp_file,
        filename: I18n.t("images.form.suggested_image_filename", author_name: photo.user.name),
        type: "image/jpeg"
      )
    end

    private

      # raises Pexels::APIError if the photo is not found or the network request fails
      def get_photo(photo_id)
        @client.photos.find(photo_id)
      end

      def download_file(uri)
        temp_file = Tempfile.new(uri.path, binmode: true)

        Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
          http.request(Net::HTTP::Get.new(uri)) do |response|
            raise PexelsError, "Network request failed" unless response.is_a?(Net::HTTPSuccess)

            response.read_body { |chunk| temp_file.write(chunk) }
            temp_file.rewind
          end
        end

        temp_file
      rescue => e
        temp_file.close!
        raise PexelsError, "Failed to download image from Pexels: #{e.message}"
      end
  end
end
