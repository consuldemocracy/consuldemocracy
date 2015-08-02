require 'rails_helper'

describe WYSIWYGSanitizer do

  subject { described_class.new }

  describe '#sanitize' do

    it 'returns an html_safe string' do
      expect(subject.sanitize('hello')).to be_html_safe
    end

    it 'allows basic html formatting' do
      html = '<p>This is <strong>a paragraph</strong></p>'
      expect(subject.sanitize(html)).to eq(html)
    end

    it 'filters out dangerous tags' do
      html = '<p>This is <script>alert("dangerous");</script></p>'
      expect(subject.sanitize(html)).to eq('<p>This is alert("dangerous");</p>')
    end
  end

end
