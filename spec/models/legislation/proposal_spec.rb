require 'rails_helper'

describe Legislation::Proposal do
  let(:proposal) { build(:legislation_proposal) }

  it "is valid" do
    expect(proposal).to be_valid
  end

  it "is not valid without a process" do
    proposal.process = nil
    expect(proposal).not_to be_valid
  end

  it "is not valid without an author" do
    proposal.author = nil
    expect(proposal).not_to be_valid
  end

  it "is not valid without a title" do
    proposal.title = nil
    expect(proposal).not_to be_valid
  end

  it "is not valid without a summary" do
    proposal.summary = nil
    expect(proposal).not_to be_valid
  end

end

# == Schema Information
#
# Table name: legislation_proposals
#
#  id                     :integer          not null, primary key
#  legislation_process_id :integer
#  title                  :string(80)
#  description            :text
#  question               :string
#  external_url           :string
#  author_id              :integer
#  hidden_at              :datetime
#  flags_count            :integer          default(0)
#  ignored_flag_at        :datetime
#  cached_votes_up        :integer          default(0)
#  comments_count         :integer          default(0)
#  confirmed_hide_at      :datetime
#  hot_score              :integer          default(0)
#  confidence_score       :integer          default(0)
#  responsible_name       :string(60)
#  summary                :text
#  video_url              :string
#  tsv                    :tsvector
#  geozone_id             :integer
#  retired_at             :datetime
#  retired_reason         :string
#  retired_explanation    :text
#  community_id           :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  cached_votes_total     :integer          default(0)
#  cached_votes_down      :integer          default(0)
#
