module WaitingForAjax
  def waiting_for_ajax
    Timeout.timeout(1) do
      loop until finished_all_ajax_requests?
    end
  end

  def finished_all_ajax_requests?
    page.evaluate_script('jQuery.active').zero?
  end
end

RSpec.configure do |config|
  config.include WaitingForAjax, type: :feature
end