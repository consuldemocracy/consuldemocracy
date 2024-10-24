RSpec::Matchers.define :have_meta do |name, with:|
  match do
    has_css?("meta[name='#{name}'][content='#{with}']", visible: false)
  end

  failure_message do
    meta = first("meta[name='#{name}']", visible: false)

    if meta
      "expected to find meta tag #{name} with '#{with}', but had '#{meta[:content]}'"
    else
      "expected to find meta tag #{name} but there were no matches."
    end
  end
end
