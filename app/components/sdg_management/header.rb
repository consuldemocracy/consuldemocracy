module SDGManagement::Header
  extend ActiveSupport::Concern

  def header
    provide(:title) do
      "#{t("sdg_management.header.title")} - #{title}"
    end

    tag.h2 title
  end
end
