require "rails_helper"

describe AdminLegislationSanitizer do
  let(:sanitizer) { AdminLegislationSanitizer.new }

  describe "#sanitize" do
    it "allows images" do
      html = 'Dangerous<img src="/smile.png" alt="Smile"> image'
      expect(sanitizer.sanitize(html)).to eq(html)
    end

    it "allows h1 to h6" do
      html = '<h1>Heading 1</h1>
              <h2>Heading 2</h2>
              <h3>Heading 3</h3>
              <h4>Heading 4</h4>
              <h5>Heading 5</h5>
              <h6>Heading 6</h6>'
      expect(sanitizer.sanitize(html)).to eq(html)
    end

    it "allows tables" do
      html = '<table>
                <thead>
                  <tr>
                    <th>id</th>
                    <th>name</th>
                    <th>age</th>
                    <th>gender</th>
                  </tr>
                </thead>
                <tbody>
                  <tr>
                    <td>1</td>
                    <td>Roberta</td>
                    <td>39</td>
                    <td>M</td>
                  </tr>
                  <tr>
                    <td>2</td>
                    <td>Oliver</td>
                    <td>25</td>
                    <td>F</td>
                  </tr>
                </tbody>
              </table>'
      expect(sanitizer.sanitize(html)).to eq(html)
    end

    it "allows alt src and id" do
      html = 'Dangerous<img src="/smile.png" alt="Smile" id="smile"> image'
      expect(sanitizer.sanitize(html)).to eq(html)
    end

    it "doesn't allow style" do
      html = 'Dangerous<img src="/smile.png" alt="Smile" style="width:10px;"> image'
      expect(sanitizer.sanitize(html)).not_to eq(html)
    end

    it "doesn't allow class" do
      html = 'Dangerous<img src="/smile.png" alt="Smile" class="smile"> image'
      expect(sanitizer.sanitize(html)).not_to eq(html)
    end
  end
end
