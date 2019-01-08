module BannersHelper

  def has_banners?
    @banners.present? && @banners.count > 0
  end

end
