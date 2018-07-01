module ActiveSupport::Testing::TimeHelpers
  # Copied from Rails 5.2. TODO: remove after migrating to Rails 5.
  def freeze_time(&block)
    travel_to Time.now, &block
  end
end

include ActiveSupport::Testing::TimeHelpers
