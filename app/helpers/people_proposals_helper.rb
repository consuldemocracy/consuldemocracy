module PeopleProposalsHelper
  def social_link(type, value)
    case type
    when "twitter" then twitter_social_link(value)
    when "facebook" then facebook_social_link(value)
    when "instagram" then instagram_social_link(value)
    when "youtube" then youtube_social_link(value)
    end
  end

  def twitter_social_link(value)
    "https://twitter.com/#{value.tr('@', '')}"
  end

  def facebook_social_link(value)
    "https://www.facebook.com/#{value.tr('@', '')}"
  end

  def instagram_social_link(value)
    "https://www.instagram.com/#{value.tr('@', '')}"
  end

  def youtube_social_link(value)
    "https://www.youtube.com/user/#{value}"
  end
end
