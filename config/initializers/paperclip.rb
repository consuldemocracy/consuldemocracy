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
