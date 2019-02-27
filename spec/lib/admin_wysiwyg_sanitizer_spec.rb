require "rails_helper"

describe AdminWYSIWYGSanitizer do
  let(:sanitizer) { AdminWYSIWYGSanitizer.new }

  describe "#sanitize" do

    it "allows images" do
      html = 'Dangerous<img src="/smile.png" alt="Smile" style="width: 10px;"> image'
      expect(sanitizer.sanitize(html)).to eq(html)
    end

    it "allows div tags" do
      html = '<div class="header">Content</div>'
      expect(sanitizer.sanitize(html)).to eq(html)
    end

    it "allows id attribute for anchors" do
      html = '<h2 id="1">Section title</h2>'
      expect(sanitizer.sanitize(html)).to eq(html)
    end

    it "allows span tags" do
      html = '<span class="icon-check"></span>'
      expect(sanitizer.sanitize(html)).to eq(html)
    end

    it "allows code tags" do
      html = "<code>code formatted text</code>"
      expect(sanitizer.sanitize(html)).to eq(html)
    end

    it "allows tables" do
      html = '<table>
                <caption>Caption Table</caption>
                <thead>
                  <tr>
                    <th scope="col">Header</th>
                  </tr>
                </thead>
                <tbody>
                  <tr>
                    <td>Value</td>
                  </tr>
                </tbody>
              </table>'
      expect(sanitizer.sanitize(html)).to eq(html)
    end

  end
end
