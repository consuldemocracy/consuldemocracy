module ApplicationHelper

  def tags(debate, limit = nil)
    tag_names = debate.tag_list_with_limit(limit)

    tag_names.sort.map do |tag|
      link_to sanitize(tag), debates_path(tag: tag)
    end.join('').html_safe.tap do |output|
      if limit && extra_tags = debate.tags_count_out_of_limit(limit)
        output.concat(link_to("#{extra_tags}+", debate_path(debate)))
      end
    end
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
