module Tags
  def tag_names(tag_cloud)
    tag_cloud.tags.map(&:name)
  end

  def type_mobile_comma(label, text)
    execute_script(<<~JS, find_field(label), text)
      var input = arguments[0];
      var text = arguments[1];

      input.focus();
      input.value = text + ",";
      input.dispatchEvent(new InputEvent("input", {
        bubbles: true,
        data: ",",
        inputType: "insertText"
      }));
    JS
  end

  def fill_in_tag_list(tags, label: "Tags")
    text = tags.to_s.strip
    text = "#{text}," unless text.empty? || text.end_with?(",")
    text = "#{text} "

    fill_in label, with: text
  end

  def remove_tag_list_tag(name)
    within ".item[data-value=\"#{name}\"]" do
      click_button "Remove"
    end
  end

  def clear_tag_list
    all(:button, "Remove").reverse_each(&:click)
  end
end
