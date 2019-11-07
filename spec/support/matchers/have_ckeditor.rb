RSpec::Matchers.define :have_ckeditor do |label, with:|
  define_method :textarea_id do
    find("label", text: label)[:for]
  end

  define_method :ckeditor_selector do
    "[aria-label~='#{textarea_id}']"
  end

  define_method :has_ckeditor? do
    has_css?("label", text: label) && has_css?(ckeditor_selector)
  end

  match do
    has_ckeditor? && has_css?(ckeditor_selector, exact_text: with)
  end

  failure_message do
    if has_ckeditor?
      text = page.find(ckeditor_selector).text

      "expected to find visible CKEditor '#{label}' with '#{with}', but had '#{text}'"
    else
      "expected to find visible CKEditor '#{label}' but there were no matches."
    end
  end
end
