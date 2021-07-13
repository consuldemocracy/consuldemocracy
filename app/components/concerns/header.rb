module Header
  extend ActiveSupport::Concern

  def header(&block)
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
      if block_given?
        content_tag(heading_tag, title) + capture(&block)
      else
        content_tag(heading_tag, title)
      end
    end
  end

  private

    def namespace
      controller_path.split("/").first
    end
end
