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

end
