module BannersHelper
  def has_banners?
    @banners.present? && @banners.count > 0
  end

  def banner_default_bg_color
    "#e7f2fc"
  end

  def banner_default_font_color
    "#222222"
  end

  def banner_bg_color_or_default
    @banner.background_color.presence || banner_default_bg_color
  end

  def banner_font_color_or_default
    @banner.font_color.presence || banner_default_font_color
  end

  def banner_target_link(banner)
    link_to banner.target_url do
      tag.h2(banner.title, style: "color:#{banner.font_color}") +
        tag.h3(banner.description, style: "color:#{banner.font_color}")
    end
  end
end
