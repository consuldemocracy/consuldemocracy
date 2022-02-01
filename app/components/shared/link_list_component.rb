class Shared::LinkListComponent < ApplicationComponent
  attr_reader :links, :options

  def initialize(*links, **options)
    @links = links
    @options = options
  end

  def render?
    present_links.any?
  end

  private

    def present_links
      links.select(&:present?)
    end

    def list_items
      present_links.map do |text, url, current = false, **link_options|
        tag.li(({ "aria-current": true } if current)) do
          if url
            link_to text, url, link_options
          else
            text
          end
        end
      end
    end
end
