namespace :homepage do

  desc "Initialize feeds available in homepage"
  task create_feeds: :environment do
    %w(proposals debates processes).each do |kind|
      Widget::Feed.create(kind: kind)
    end
  end

end