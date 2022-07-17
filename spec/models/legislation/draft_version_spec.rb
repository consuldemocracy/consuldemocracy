require "rails_helper"

describe Legislation::DraftVersion do
  let(:legislation_draft_version) { build(:legislation_draft_version) }

  it_behaves_like "acts as paranoid", :legislation_draft_version
  it_behaves_like "globalizable", :legislation_draft_version

  it "is valid" do
    expect(legislation_draft_version).to be_valid
  end

  it "dynamically validates the valid statuses" do
    stub_const("#{Legislation::DraftVersion}::VALID_STATUSES", %w[custom])

    legislation_draft_version.status = "custom"
    expect(legislation_draft_version).to be_valid

    legislation_draft_version.status = "published"
    expect(legislation_draft_version).not_to be_valid
  end

  it "renders the html from the markdown body field" do
    legislation_draft_version.body = body_markdown

    legislation_draft_version.save!

    expect(legislation_draft_version.body_html).to eq(body_html)
    expect(legislation_draft_version.toc_html).to eq(toc_html)
  end

  def body_markdown
    <<~BODY_MARKDOWN
      # Title 1

      ---

      Some paragraph.

      > Blockquote

      A list:

      - item 1
      - item 2

      ## Subtitle

      Another paragraph.

      # Title 2

      Something about this.

      `code`

      | Syntax | Description |
      | ----------- | ----------- |
      | Header | Title |
      | Paragraph | Text |
    BODY_MARKDOWN
  end

  def body_html
    <<~BODY_HTML
      <h1 id="title-1">Title 1</h1>

      <hr>

      <p>Some paragraph.</p>

      <blockquote>
      <p>Blockquote</p>
      </blockquote>

      <p>A list:</p>

      <ul>
      <li>item 1</li>
      <li>item 2</li>
      </ul>

      <h2 id="subtitle">Subtitle</h2>

      <p>Another paragraph.</p>

      <h1 id="title-2">Title 2</h1>

      <p>Something about this.</p>

      <p><code>code</code></p>

      <table><thead>
      <tr>
      <th>Syntax</th>
      <th>Description</th>
      </tr>
      </thead><tbody>
      <tr>
      <td>Header</td>
      <td>Title</td>
      </tr>
      <tr>
      <td>Paragraph</td>
      <td>Text</td>
      </tr>
      </tbody></table>
    BODY_HTML
  end

  def toc_html
    <<~TOC_HTML
      <ul>
      <li>
      <a href="#title-1">Title 1</a>
      <ul>
      <li>
      <a href="#subtitle">Subtitle</a>
      </li>
      </ul>
      </li>
      <li>
      <a href="#title-2">Title 2</a>
      </li>
      </ul>
    TOC_HTML
  end
end
