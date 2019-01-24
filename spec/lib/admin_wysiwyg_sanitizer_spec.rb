require 'rails_helper'

describe AdminWYSIWYGSanitizer do
  let(:sanitizer) { AdminWYSIWYGSanitizer.new }

  describe '#sanitize' do
    it 'allows images' do
      html = 'Dangerous<img src="/smile.png" alt="Smile" style="width: 10px;"> image'
      expect(sanitizer.sanitize(html)).to eq(html)
    end
  end
end
