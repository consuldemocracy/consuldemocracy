module BannersHelper
  def has_banners?
    @banners.present? && @banners.count > 0
  end

  def banner_target_link(banner)
    link_to banner.target_url do
      tag.h2(banner.title, style: "color:#{banner.font_color}") +
        tag.h3(banner.description, style: "color:#{banner.font_color}")
    end
  end
end
