module ApplicationHelper

  def percentage(vote, debate)
    return "0%" if debate.total_votes == 0
    debate.send(vote).percent_of(debate.total_votes).to_s + "%"
  end

  def home_page?
    # Using path because fullpath yields false negatives since it contains
    # parameters too
    request.path == '/'
  end

  def transparency_page?
    request.path == '/transparency'
  end

  def opendata_page?
    request.path == '/opendata'
  end

  def header_css
    home_page? || transparency_page? || opendata_page? ? '' : 'results'
  end

  # if current path is /debates current_path_with_query_params(foo: 'bar') returns /debates?foo=bar
  # notice: if query_params have a param which also exist in current path, it "overrides" (query_params is merged last)
  def current_path_with_query_params(query_parameters)
    url_for(request.query_parameters.merge(query_parameters))
  end

end
