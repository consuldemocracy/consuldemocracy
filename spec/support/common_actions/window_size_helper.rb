module WindowSizeHelper
  def with_window_size(width, height, &block)
    original_size = Capybara.current_window.size
    Capybara.current_window.resize_to(width, height)
    block.call
  ensure
    Capybara.current_window.resize_to(*original_size)
  end

  def with_small_window(&)
    with_window_size(320, 640, &)
  end
end
