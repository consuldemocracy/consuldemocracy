require "rails_helper"

describe AdminWYSIWYGSanitizer do
  let(:sanitizer) { AdminWYSIWYGSanitizer.new }

  describe "#sanitize" do
    it "allows images" do
      html = 'Dangerous<img src="/smile.png" alt="Smile" style="width:10px;"> image'
      expect(sanitizer.sanitize(html)).to eq(html)
    end

    it "allows tables" do
      html = '<table align="center" border="2" cellpadding="2" cellspacing="2" dir="ltr" ' \
                    'id="table_id" class="stylesheet_classes" style="height:200px;width:500px;" ' \
                    'summary="summary">
                <caption>caption</caption>
                <tbody>
                  <tr>
                    <th scope="row">header 1</th>
                    <td>cell 1</td>
                  </tr>
                  <tr>
                    <th scope="row">header 2</th>
                    <td>cell 2</td>
                  </tr>
                </tbody>
              </table>'
      expect(sanitizer.sanitize(html)).to eq(html)
    end
  end
end
