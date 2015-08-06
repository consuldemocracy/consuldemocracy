module ApplicationHelper

  def tags(debate)
    debate.tag_list.sort.map { |tag| link_to sanitize(tag), debates_path(tag: tag) }.join('').html_safe
  end

  def percentage(vote, debate)
    return "0%" if debate.total_votes == 0
    debate.send(vote).percent_of(debate.total_votes).to_s + "%"
  end

  def home_page?
    # Using path because fullpath yields false negatives since it contains
    # parameters too
    request.path == '/'
  end

  def header_css
    home_page? ? '' : 'results'
  end

  def available_locales_to_switch
    I18n.available_locales - [I18n.locale]
  end
end
