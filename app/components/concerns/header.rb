module Header
  extend ActiveSupport::Concern

  def header(before: nil, &block)
    provide(:title) do
      [
        t("#{namespace}.header.title", default: ""),
        strip_tags(title),
        setting["org_name"]
      ].reject(&:blank?).join(" - ")
    end

    heading_tag = if %w[admin management moderation sdg_management valuation].include?(namespace)
                    "h2"
                  else
                    "h1"
                  end

    tag.header do
      safe_join([before, content_tag(heading_tag, title), (capture(&block) if block)].compact)
    end
  end

  private

    def namespace
      controller_path.split("/").first
    end
end
