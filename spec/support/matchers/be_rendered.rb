RSpec::Matchers.define :be_rendered do |with: nil|
  match do |page|
    if with.nil?
      !page.native.inner_html.empty?
    else
      page.has_css?("body") && page.find("body").native.inner_html == with
    end
  end

  failure_message do |page|
    if page.has_css?("body")
      "expected page to be rendered with #{with}, but was rendered with #{page.find("body").native.inner_html}"
    else
      "expected page to be rendered with #{with}, but was not rendered"
    end
  end

  failure_message_when_negated do |page|
    if page.has_css?("body")
      "expected page not to be rendered, but was rendered with #{page.find("body").native.inner_html}"
    else
      "expected page not to be rendered, but was rendered with #{page.native.inner_html}"
    end
  end
end
