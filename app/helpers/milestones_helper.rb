module MilestonesHelper
  def progress_tag_for(progress_bar)
    text = number_to_percentage(progress_bar.percentage, precision: 0)

    content_tag :span do
      content_tag(:span, "", "data-text": text, style: "width: #{progress_bar.percentage}%;") +
      content_tag(:progress,
                  text,
                  class: progress_bar.primary? ? "primary" : "",
                  max: ProgressBar::RANGE.max,
                  value: progress_bar.percentage)
    end
  end
end
