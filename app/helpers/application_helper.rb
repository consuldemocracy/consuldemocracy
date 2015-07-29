module ApplicationHelper

  def tags(debate)
    debate.tag_list.sort.map { |tag| link_to sanitize(tag), debates_path(tag: tag) }.join('').html_safe
  end

  def percentage(vote, debate)
    return if debate.total_votes == 0
    debate.send(vote).percent_of(debate.total_votes).to_s + "%"
  end

  def home_page?
    request.fullpath == '/'
  end

  def header_css
    home_page? ? '' : 'results'
  end
end
