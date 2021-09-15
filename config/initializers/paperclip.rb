if Rails.env.production? || Rails.env.staging? || Rails.env.preproduction?
  Paperclip::Attachment.default_options[:storage] = :s3
  Paperclip::Attachment.default_options[:s3_host_name] = Rails.application.secrets.dig(:s3, :host_name)
  Paperclip::Attachment.default_options[:s3_protocol] = :https
  Paperclip::Attachment.default_options[:s3_credentials] = {
    access_key_id: Rails.application.secrets.dig(:s3, :access_key_id),
    secret_access_key: Rails.application.secrets.dig(:s3, :secret_access_key),
    s3_region: Rails.application.secrets.dig(:s3, :region)
  }
  Paperclip::Attachment.default_options[:bucket] = Rails.application.secrets.dig(:s3, :bucket)
end

class Paperclip::UrlGenerator
  private

    # Code copied from the paperclip gem, only replacing
    # `URI.escape` with `URI::DEFAULT_PARSER.escape`
    def escape_url(url)
      if url.respond_to?(:escape)
        url.escape
      else
        URI::DEFAULT_PARSER.escape(url).gsub(escape_regex) { |m| "%#{m.ord.to_s(16).upcase}" }
      end
    end
end
