module ApplicationHelper

  def tags(debate)
    debate.tag_list.map { |tag| link_to sanitize(tag), debates_path(tag: tag) }.join(', ').html_safe
  end

end
