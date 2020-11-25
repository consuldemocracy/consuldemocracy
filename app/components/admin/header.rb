module Admin::Header
  extend ActiveSupport::Concern

  def header(options: {})
    provide(:title) do
      title
    end

    tag.h2 options do
      title
    end
  end
end
