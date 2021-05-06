class Layout::TopLinksComponent < ApplicationComponent
  delegate :content_block, to: :helpers
end
