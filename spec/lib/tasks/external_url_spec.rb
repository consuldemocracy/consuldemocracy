require 'rails_helper'
require 'rake'

describe 'rake external_url:investments' do

  before do
    @investment = create(:budget_investment, external_url: "http://www.url.com")

    Rake.application.rake_require "tasks/external_url"
    Rake::Task.define_task(:environment)
  end

  it 'remove content from external_url an insert into description' do
    expected_text = "\r\n\r\n<p><strong>Additional documentation: </strong>#{@investment.external_url}</p>".html_safe
    Rake::Task["external_url:investments"].invoke

    expect(Budget::Investment.all.map(&:external_url).compact).to eq []
    expect(Budget::Investment.last.description).to include expected_text
  end

end

describe 'rake external_url:proposals' do

  before do
    @proposal = create(:proposal, external_url: "http://www.url.com")

    Rake.application.rake_require "tasks/external_url"
    Rake::Task.define_task(:environment)
  end

  it 'remove content from external_url an insert into description' do
    expected_text = "\r\n\r\n<p><strong>Additional documentation: </strong>#{@proposal.external_url}</p>".html_safe
    Rake::Task["external_url:proposals"].invoke

    expect(Proposal.all.map(&:external_url).compact).to eq []
    expect(Proposal.last.description).to include expected_text
  end
end
