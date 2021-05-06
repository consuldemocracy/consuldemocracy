class Layout::SocialComponent < ApplicationComponent
  delegate :content_block, to: :helpers
end
