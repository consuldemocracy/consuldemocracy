RSpec::Matchers.define :have_ckeditor do |label, with:|
  match do
    return false unless has_css?(".ckeditor", text: label)

    page.within(".ckeditor", text: label) do
      within_frame(0) { has_content?(with) }
    end
  end

  failure_message do
    if has_css?(".ckeditor", text: label)
      text = page.within(".ckeditor", text: label) { within_frame(0) { page.text } }

      "expected to find visible CKEditor '#{label}' with '#{with}', but had '#{text}'"
    else
      "expected to find visible CKEditor '#{label}' but there were no matches."
    end
  end
end
