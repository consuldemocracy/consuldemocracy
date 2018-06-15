namespace :homepage do

  desc "Initialize feeds available in homepage"
  task create_feeds: :environment do
    %w(proposals debates processes).each do |kind|
      Widget::Feed.create(kind: kind)

      Setting['feature.homepage.widgets.feeds.proposals'] = true
      Setting['feature.homepage.widgets.feeds.debates'] = true
      Setting['feature.homepage.widgets.feeds.processes'] = true
    end
  end
end
