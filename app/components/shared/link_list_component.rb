class Shared::LinkListComponent < ApplicationComponent
  attr_reader :links, :options

  def initialize(*links, **options)
    @links = links
    @options = options
  end

  def render?
    links.select(&:present?).any?
  end

  def call
    tag.ul(options) do
      safe_join(links.select(&:present?).map do |text, url, current = false, **link_options|
        tag.li(({ "aria-current": true } if current)) do
          if url
            link_to text, url, link_options
          else
            text
          end
        end
      end, "\n")
    end
  end
end
