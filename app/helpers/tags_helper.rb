module TagsHelper

  def taggable_path(taggable_type, tag_name)
    case taggable_type
    when 'debate'
      debates_path(search: tag_name)
    when 'proposal'
      proposals_path(search: tag_name)
    else
      '#'
    end
  end

  def display_tag_list(resource)
    tag_list = resource.tag_list.to_s

    if resource.tag_list.count == 1
       tag_list += ","
    end
    tag_list
  end

end
