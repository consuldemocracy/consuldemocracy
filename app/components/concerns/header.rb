module Header
  extend ActiveSupport::Concern

  def header(&block)
    provide(:title) do
      "#{t("#{namespace}.header.title")} - #{title}"
    end

    tag.header do
      if block_given?
        tag.h2(title) + capture(&block)
      else
        tag.h2(title)
      end
    end
  end

  private

    def namespace
      controller_path.split("/").first
    end
end
