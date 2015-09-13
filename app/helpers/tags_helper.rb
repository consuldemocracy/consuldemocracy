module TagsHelper

  def taggable_path(taggable, tag_name)
    case taggable
    when 'debate'
      debates_path(tag: tag_name)
    when 'proposal'
      proposals_path(tag: tag_name)
    else
      '#'
    end
  end

end
