class Shared::BannerComponent < ApplicationComponent
  attr_reader :banner

  def initialize(banner)
    @banner = banner
  end

  private

    def link
      link_to banner.target_url do
        tag.h2(banner.title, style: "color:#{banner.font_color}") +
          tag.h3(banner.description, style: "color:#{banner.font_color}")
      end
    end
end
