module BannersHelper

  def has_banners?
    @banners.present? && @banners.count > 0
  end
  
  def is_banner_on_top?
    @banners.sample.banner_position == "Top" || @banners.sample.banner_position.nil?
  end
  
  def is_banner_on_bottom?
    @banners.sample.banner_position == "Bottom"
  end    

end
