RSpec::Matchers.define :appear_before do |later_content|
  match do |earlier_content|
    text = page.text
    text.index(earlier_content) < text.index(later_content)
  end
end
