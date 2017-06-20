module ApplicationHelper

  def home_page?
    return false if user_signed_in?
    # Using path because fullpath yields false negatives since it contains
    # parameters too
    request.path == '/'
  end

  def opendata_page?
    request.path == '/opendata'
  end

  # if current path is /debates current_path_with_query_params(foo: 'bar') returns /debates?foo=bar
  # notice: if query_params have a param which also exist in current path, it "overrides" (query_params is merged last)
  def current_path_with_query_params(query_parameters)
    url_for(request.query_parameters.merge(query_parameters))
  end

  def markdown(text)
    # See https://github.com/vmg/redcarpet for options
    render_options = {
      filter_html:     false,
      hard_wrap:       true,
      link_attributes: {  target: "_blank" }
    }
    renderer = Redcarpet::Render::HTML.new(render_options)
    extensions = {
      autolink:           true,
      fenced_code_blocks: true,
      lax_spacing:        true,
      no_intra_emphasis:  true,
      strikethrough:      true,
      superscript:        true
    }
    Redcarpet::Markdown.new(renderer, extensions).render(text).html_safe
  end

  def author_of?(authorable, user)
    return false if authorable.blank? || user.blank?
    authorable.author_id == user.id
  end

  def back_link_to(destination_path)
    destination = destination_path || :back
    link_to destination, class: "back" do
      "<span class='icon-angle-left'></span>".html_safe + t("shared.back")
    end
  end

  def image_path_for(filename)
    SiteCustomization::Image.image_path_for(filename) || filename
  end

  def content_block(name, locale)
    SiteCustomization::ContentBlock.block_for(name, locale)
  end

  def abre_log(text = nil)
    p 'abre_log : ' + (text.nil? ? caller[0].to_s : text.to_s)
  end

  def distance_of_time_in_days(from_time, to_time = 0)
    from_time = from_time.to_time if from_time.respond_to?(:to_time)
    to_time = to_time.to_time if to_time.respond_to?(:to_time)
    from_time, to_time = to_time, from_time if from_time > to_time
    distance_in_days = (((to_time - from_time).abs) / 86400).round
  end
  
end
