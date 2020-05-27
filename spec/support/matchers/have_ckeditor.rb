RSpec::Matchers.define :have_ckeditor do |label, with:|
  define_method :textarea_id do
    find("label", text: label)[:for]
  end

  define_method :ckeditor_id do
    "#cke_#{textarea_id}"
  end

  define_method :has_ckeditor? do
    has_css?("label", text: label) && has_css?(ckeditor_id)
  end

  match do
    return false unless has_ckeditor?

    until page.execute_script("return CKEDITOR.instances.#{textarea_id}.status === 'ready';") do
      sleep 0.01
    end

    page.within(ckeditor_id) do
      within_frame(0) { has_content?(with, exact: true) }
    end
  end

  failure_message do
    if has_ckeditor?
      text = page.within(ckeditor_id) { within_frame(0) { page.text } }

      "expected to find visible CKEditor '#{label}' with '#{with}', but had '#{text}'"
    else
      "expected to find visible CKEditor '#{label}' but there were no matches."
    end
  end
end
