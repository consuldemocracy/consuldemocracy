RSpec::Matchers.define :have_property do |property, with:|
  match do
    has_css?("meta[property='#{property}'][content='#{with}']", visible: false)
  end

  failure_message do
    meta = first("meta[property='#{property}']", visible: false)

    if meta
      "expected to find meta tag #{property} with '#{with}', but had '#{meta[:content]}'"
    else
      "expected to find meta tag #{property} but there were no matches."
    end
  end
end
