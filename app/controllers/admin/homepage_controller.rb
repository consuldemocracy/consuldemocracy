class Admin::HomepageController < Admin::BaseController

  def show
    load_header
    load_feeds
    load_recommendations
    load_cards
  end

  private

  def load_header
    @header = ::Widget::Card.header
  end

  def load_recommendations
    @recommendations = Setting.where(key: 'feature.user.recommendations').first
  end

  def load_cards
    @cards = ::Widget::Card.body
  end

  def load_feeds
    @feeds = Widget::Feed.order("created_at")
  end

end