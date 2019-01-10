module MilestonesHelper
  def progress_tag_for(progress_bar)
    content_tag :progress,
                number_to_percentage(progress_bar.percentage, precision: 0),
                class: progress_bar.primary? ? "primary" : "",
                max: ProgressBar::RANGE.max,
                value: progress_bar.percentage
  end
end
