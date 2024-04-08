RSpec::Matchers.define :have_avatar do |name, **options|
  match do
    has_css?("img.initialjs-avatar[data-name='#{name}'][src^='data:image/svg']", **options)
  end

  failure_message do
    "expected to find avatar with name #{name} but there were no matches."
  end
end
