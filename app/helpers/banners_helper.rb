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
  
  def is_banner_heading_on_top?(heading_id)
    if (@banners.sample.headings != nil) && (@banners.sample.headings.include? heading_id.to_s)
      @banners.sample.banner_position == "Top" || @banners.sample.banner_position.nil?
    else
      false
    end  
  end
  
  def is_banner_heading_on_bottom?(heading_id)
    if (@banners.sample.headings != nil) && (@banners.sample.headings.include? heading_id.to_s)
      @banners.sample.banner_position == "Bottom"
    else
      false
    end  
  end
       
end
