RSpec::Matchers.define :be_rendered do
  match do |page|
    !page.native.inner_html.empty?
  end

  failure_message_when_negated do |page|
    if page.has_css?("body")
      "expected page not to be rendered, but was rendered with #{page.find("body").native.inner_html}"
    else
      "expected page not to be rendered, but was rendered with #{page.native.inner_html}"
    end
  end
end
