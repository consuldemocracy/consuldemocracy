class MarkdownConverter
  attr_reader :text, :render_options

  def initialize(text, **render_options)
    @text = text
    @render_options = render_options
  end

  def render
    return text if text.blank?

    AdminLegislationSanitizer.new.sanitize(Redcarpet::Markdown.new(renderer, extensions).render(text))
  end

  def render_toc
    Redcarpet::Markdown.new(toc_renderer).render(text)
  end

  private

    def renderer
      Redcarpet::Render::HTML.new(default_render_options.merge(render_options))
    end

    def toc_renderer
      Redcarpet::Render::HTML_TOC.new(with_toc_data: true)
    end

    def default_render_options
      {
        filter_html: false,
        hard_wrap: true,
        link_attributes: {}
      }
    end

    def extensions
      {
        autolink: true,
        fenced_code_blocks: true,
        lax_spacing: true,
        no_intra_emphasis: true,
        strikethrough: true,
        superscript: true,
        tables: true
      }
    end
end
