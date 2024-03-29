RSpec::Matchers.define :have_avatar do |text, **options|
  match do
    has_css?("svg.initialjs-avatar", **{ exact_text: text }.merge(options))
  end

  failure_message do
    "expected to find avatar with text #{text} but there were no matches."
  end
end
