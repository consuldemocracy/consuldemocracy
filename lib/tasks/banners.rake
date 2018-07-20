namespace :banners do

  desc "Migrate styles to background_color and font_color"
  task migrate_style: :environment do

    Banner.all.each do |banner|
      banner.font_color = '#FFFFFF'
      case banner.style
      when "banner-style banner-style-one"
        banner.background_color = '#004a83'
      when "banner-style banner-style-two"
        banner.background_color = '#7e328a'
      when "banner-style banner-style-three"
        banner.background_color = '#33dadf'
      end
      banner.save
    end
  end

end
