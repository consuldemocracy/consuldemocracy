require 'rails_helper'

RSpec.describe Legislation::DraftVersion, type: :model do
    let(:legislation_draft_version) { build(:legislation_draft_version) }

  it "is valid" do
    expect(legislation_draft_version).to be_valid
  end

  it "renders and saves the html from the markdown body field" do
    legislation_draft_version.body = body_markdown

    legislation_draft_version.save!

    expect(legislation_draft_version.body_html).to eq(body_html)
    expect(legislation_draft_version.toc_html).to eq(toc_html)
  end

  it "renders and saves the html from the markdown body field with alternative translation" do
    legislation_draft_version.body_fr = body_markdown

    legislation_draft_version.save!

    expect(legislation_draft_version.body_html_fr).to eq(body_html)
    expect(legislation_draft_version.toc_html_fr).to eq(toc_html)
  end

  def body_markdown
<<-BODY_MARKDOWN
# Title 1

Some paragraph.

A list:

- item 1
- item 2

## Subtitle

Another paragraph.

# Title 2

Something about this.
BODY_MARKDOWN
  end

  def body_html
<<-BODY_HTML
<h1 id="title-1">Title 1</h1>

<p>Some paragraph.</p>

<p>A list:</p>

<ul>
<li>item 1</li>
<li>item 2</li>
</ul>

<h2 id="subtitle">Subtitle</h2>

<p>Another paragraph.</p>

<h1 id="title-2">Title 2</h1>

<p>Something about this.</p>
BODY_HTML
  end

  def toc_html
<<-TOC_HTML
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
