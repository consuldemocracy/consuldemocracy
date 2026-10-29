module Tags
  def tag_names(tag_cloud)
    tag_cloud.tags.map(&:name)
  end

  def fill_in_tag_list(tags, within: ".js-taggable-fields")
    text = tags.to_s.strip
    unless text.empty?
      text = "#{text}," unless text.end_with?(",")
      text = "#{text} "
    end

    within(within) do
      find(:css, ".js-tag-list-input").set(text)
    end
  end

  def remove_tag_list_tag(name, within: ".js-taggable-fields")
    within within do
      within "span[data-val=\"#{name}\"]" do
        click_button "Remove"
      end
    end
  end

  def clear_tag_list(within: ".js-taggable-fields")
    within(within) do
      all(".amsify-suggestags-input-area button.remove-tag").reverse_each(&:click)
    end
  end
end
