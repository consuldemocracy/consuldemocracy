require "rails_helper"

api_types  = GraphQL::ApiTypesCreator.create(API_TYPE_DEFINITIONS)
query_type = GraphQL::QueryTypeCreator.create(api_types)
ConsulSchema = GraphQL::Schema.define do
  query query_type
  max_depth 12
end

def execute(query_string, context = {}, variables = {})
  ConsulSchema.execute(query_string, context: context, variables: variables)
end

def dig(response, path)
  response.dig(*path.split("."))
end

def hidden_field?(response, field_name)
  data_is_empty = response["data"].nil?
  error_is_present = ((response["errors"].first["message"] =~ /Field '#{field_name}' doesn't exist on type '[[:alnum:]]*'/) == 0)
  data_is_empty && error_is_present
end

def extract_fields(response, collection_name, field_chain)
  fields = field_chain.split(".")
  dig(response, "data.#{collection_name}.edges").collect do |node|
    begin
      if fields.size > 1
        node["node"][fields.first][fields.second]
      else
        node["node"][fields.first]
      end
    rescue NoMethodError
    end
  end.compact
end

describe "Consul Schema" do
  let(:user) { create(:user) }
  let(:proposal) { create(:proposal, author: user) }

  it "returns fields of Int type" do
    response = execute("{ proposal(id: #{proposal.id}) { id } }")
    expect(dig(response, "data.proposal.id")).to eq(proposal.id)
  end

  it "returns fields of String type" do
    response = execute("{ proposal(id: #{proposal.id}) { title } }")
    expect(dig(response, "data.proposal.title")).to eq(proposal.title)
  end

  xit "returns has_one associations" do
    organization = create(:organization)
    response = execute("{ user(id: #{organization.user_id}) { organization { name } } }")
    expect(dig(response, "data.user.organization.name")).to eq(organization.name)
  end

  it "returns belongs_to associations" do
    response = execute("{ proposal(id: #{proposal.id}) { public_author { username } } }")
    expect(dig(response, "data.proposal.public_author.username")).to eq(proposal.public_author.username)
  end

  it "returns has_many associations" do
    comments_author = create(:user)
    comment_1 = create(:comment, author: comments_author, commentable: proposal)
    comment_2 = create(:comment, author: comments_author, commentable: proposal)

    response = execute("{ proposal(id: #{proposal.id}) { comments { edges { node { body } } } } }")
    comments = dig(response, "data.proposal.comments.edges").collect { |edge| edge["node"] }
    comment_bodies = comments.collect { |comment| comment["body"] }

    expect(comment_bodies).to match_array([comment_1.body, comment_2.body])
  end

  xit "executes deeply nested queries" do
    org_user = create(:user)
    organization = create(:organization, user: org_user)
    org_proposal = create(:proposal, author: org_user)
    response = execute("{ proposal(id: #{org_proposal.id}) { public_author { organization { name } } } }")

    expect(dig(response, "data.proposal.public_author.organization.name")).to eq(organization.name)
  end

  it "hides confidential fields of Int type" do
    response = execute("{ user(id: #{user.id}) { failed_census_calls_count } }")
    expect(hidden_field?(response, "failed_census_calls_count")).to be_truthy
  end

  it "hides confidential fields of String type" do
    response = execute("{ user(id: #{user.id}) { encrypted_password } }")
    expect(hidden_field?(response, "encrypted_password")).to be_truthy
  end

  it "hides confidential has_one associations" do
    user.administrator = create(:administrator)
    response = execute("{ user(id: #{user.id}) { administrator { id } } }")
    expect(hidden_field?(response, "administrator")).to be_truthy
  end

  it "hides confidential belongs_to associations" do
    create(:failed_census_call, user: user)
    response = execute("{ user(id: #{user.id}) { failed_census_calls { id } } }")
    expect(hidden_field?(response, "failed_census_calls")).to be_truthy
  end

  it "hides confidential has_many associations" do
    create(:direct_message, sender: user)
    response = execute("{ user(id: #{user.id}) { direct_messages_sent { id } } }")
    expect(hidden_field?(response, "direct_messages_sent")).to be_truthy
  end

  it "hides confidential fields inside deeply nested queries" do
    response = execute("{ proposals(first: 1) { edges { node { public_author { encrypted_password } } } } }")
    expect(hidden_field?(response, "encrypted_password")).to be_truthy
  end

  describe "Users" do
    let(:user) { create(:user, public_activity: false) }

    it "does not link debates if activity is not public" do
      create(:debate, author: user)

      response = execute("{ user(id: #{user.id}) { public_debates { edges { node { title } } } } }")
      received_debates = dig(response, "data.user.public_debates.edges")

      expect(received_debates).to eq []
    end

    it "does not link proposals if activity is not public" do
      create(:proposal, author: user)

      response = execute("{ user(id: #{user.id}) { public_proposals { edges { node { title } } } } }")
      received_proposals = dig(response, "data.user.public_proposals.edges")

      expect(received_proposals).to eq []
    end

    it "does not link comments if activity is not public" do
      create(:comment, author: user)

      response = execute("{ user(id: #{user.id}) { public_comments { edges { node { body } } } } }")
      received_comments = dig(response, "data.user.public_comments.edges")

      expect(received_comments).to eq []
    end

  end

  describe "Proposals" do
    it "does not include hidden proposals" do
      visible_proposal = create(:proposal)
      hidden_proposal  = create(:proposal, :hidden)

      response = execute("{ proposals { edges { node { title } } } }")
      received_titles = extract_fields(response, "proposals", "title")

      expect(received_titles).to match_array [visible_proposal.title]
    end

    xit "only returns proposals of the Human Rights proceeding" do
      proposal = create(:proposal)
      human_rights_proposal = create(:proposal, proceeding: "Derechos Humanos", sub_proceeding: "Right to have a job")
      other_proceeding_proposal = create(:proposal)
      other_proceeding_proposal.update_attribute(:proceeding, "Another proceeding")

      response = execute("{ proposals { edges { node { title } } } }")
      received_titles = extract_fields(response, "proposals", "title")

      expect(received_titles).to match_array [proposal.title, human_rights_proposal.title]
    end

    it "includes proposals of authors even if public activity is set to false" do
      visible_author = create(:user, public_activity: true)
      hidden_author  = create(:user, public_activity: false)

      visible_proposal = create(:proposal, author: visible_author)
      hidden_proposal  = create(:proposal, author: hidden_author)

      response = execute("{ proposals { edges { node { title } } } }")
      received_titles = extract_fields(response, "proposals", "title")

      expect(received_titles).to match_array [visible_proposal.title, hidden_proposal.title]
    end

    it "does not link author if public activity is set to false" do
      visible_author = create(:user, public_activity: true)
      hidden_author  = create(:user, public_activity: false)

      visible_proposal = create(:proposal, author: visible_author)
      hidden_proposal  = create(:proposal, author: hidden_author)

      response = execute("{ proposals { edges { node { public_author { username } } } } }")
      received_authors = extract_fields(response, "proposals", "public_author.username")

      expect(received_authors).to match_array [visible_author.username]
    end

    it "only returns date and hour for created_at" do
      created_at = Time.zone.parse("2017-12-31 9:30:15")
      create(:proposal, created_at: created_at)

      response = execute("{ proposals { edges { node { public_created_at } } } }")
      received_timestamps = extract_fields(response, "proposals", "public_created_at")

      expect(Time.zone.parse(received_timestamps.first)).to eq Time.zone.parse("2017-12-31 9:00:00")
    end

    it "only retruns tags with kind nil or category" do
      tag          = create(:tag, name: "Parks")
      category_tag = create(:tag, :category, name: "Health")
      admin_tag    = create(:tag, name: "Admin tag", kind: "admin")

      proposal = create(:proposal, tag_list: "Parks, Health, Admin tag")

      response = execute("{ proposal(id: #{proposal.id}) { tags  { edges { node { name } } } } }")
      received_tags = dig(response, "data.proposal.tags.edges").map { |node| node["node"]["name"] }

      expect(received_tags).to match_array ["Parks", "Health"]
    end

    it "returns nested votes for a proposal" do
      proposal = create(:proposal)
      2.times { create(:vote, votable: proposal) }

      response = execute("{ proposal(id: #{proposal.id}) { votes_for { edges { node { public_created_at } } } } }")

      votes = response["data"]["proposal"]["votes_for"]["edges"]
      expect(votes.count).to eq(2)
    end

  end

  describe "Debates" do
    it "does not include hidden debates" do
      visible_debate = create(:debate)
      hidden_debate  = create(:debate, :hidden)

      response = execute("{ debates { edges { node { title } } } }")
      received_titles = extract_fields(response, "debates", "title")

      expect(received_titles).to match_array [visible_debate.title]
    end

    it "includes debates of authors even if public activity is set to false" do
      visible_author = create(:user, public_activity: true)
      hidden_author  = create(:user, public_activity: false)

      visible_debate = create(:debate, author: visible_author)
      hidden_debate  = create(:debate, author: hidden_author)

      response = execute("{ debates { edges { node { title } } } }")
      received_titles = extract_fields(response, "debates", "title")

      expect(received_titles).to match_array [visible_debate.title, hidden_debate.title]
    end

    it "does not link author if public activity is set to false" do
      visible_author = create(:user, public_activity: true)
      hidden_author  = create(:user, public_activity: false)

      visible_debate = create(:debate, author: visible_author)
      hidden_debate  = create(:debate, author: hidden_author)

      response = execute("{ debates { edges { node { public_author { username } } } } }")
      received_authors = extract_fields(response, "debates", "public_author.username")

      expect(received_authors).to match_array [visible_author.username]
    end

    it "only returns date and hour for created_at" do
      created_at = Time.zone.parse("2017-12-31 9:30:15")
      create(:debate, created_at: created_at)

      response = execute("{ debates { edges { node { public_created_at } } } }")
      received_timestamps = extract_fields(response, "debates", "public_created_at")

      expect(Time.zone.parse(received_timestamps.first)).to eq Time.zone.parse("2017-12-31 9:00:00")
    end

    it "only retruns tags with kind nil or category" do
      tag          = create(:tag, name: "Parks")
      category_tag = create(:tag, :category, name: "Health")
      admin_tag    = create(:tag, name: "Admin tag", kind: "admin")

      debate = create(:debate, tag_list: "Parks, Health, Admin tag")

      response = execute("{ debate(id: #{debate.id}) { tags  { edges { node { name } } } } }")
      received_tags = dig(response, "data.debate.tags.edges").map { |node| node["node"]["name"] }

      expect(received_tags).to match_array ["Parks", "Health"]
    end
  end

  describe "Comments" do
    it "only returns comments from proposals, debates and polls" do
      proposal_comment          = create(:comment, commentable: create(:proposal))
      debate_comment            = create(:comment, commentable: create(:debate))
      poll_comment              = create(:comment, commentable: create(:poll))
      spending_proposal_comment = build(:comment, commentable: create(:spending_proposal)).save(skip_validation: true)

      response = execute("{ comments { edges { node { commentable_type } } } }")
      received_commentables = extract_fields(response, "comments", "commentable_type")

      expect(received_commentables).to match_array ["Proposal", "Debate", "Poll"]
    end

    it "displays comments of authors even if public activity is set to false" do
      visible_author = create(:user, public_activity: true)
      hidden_author  = create(:user, public_activity: false)

      visible_comment = create(:comment, user: visible_author)
      hidden_comment  = create(:comment, user: hidden_author)

      response = execute("{ comments { edges { node { body } } } }")
      received_comments = extract_fields(response, "comments", "body")

      expect(received_comments).to match_array [visible_comment.body, hidden_comment.body]
    end

    it "does not link author if public activity is set to false" do
      visible_author = create(:user, public_activity: true)
      hidden_author  = create(:user, public_activity: false)

      visible_comment = create(:comment, author: visible_author)
      hidden_comment  = create(:comment, author: hidden_author)

      response = execute("{ comments { edges { node { public_author { username } } } } }")
      received_authors = extract_fields(response, "comments", "public_author.username")

      expect(received_authors).to match_array [visible_author.username]
    end

    it "does not include hidden comments" do
      visible_comment = create(:comment)
      hidden_comment  = create(:comment, hidden_at: Time.current)

      response = execute("{ comments { edges { node { body } } } }")
      received_comments = extract_fields(response, "comments", "body")

      expect(received_comments).to match_array [visible_comment.body]
    end

    it "does not include comments from hidden proposals" do
      visible_proposal = create(:proposal)
      hidden_proposal  = create(:proposal, hidden_at: Time.current)

      visible_proposal_comment = create(:comment, commentable: visible_proposal)
      hidden_proposal_comment  = create(:comment, commentable: hidden_proposal)

      response = execute("{ comments { edges { node { body } } } }")
      received_comments = extract_fields(response, "comments", "body")

      expect(received_comments).to match_array [visible_proposal_comment.body]
    end

    it "does not include comments from hidden debates" do
      visible_debate = create(:debate)
      hidden_debate  = create(:debate, hidden_at: Time.current)

      visible_debate_comment = create(:comment, commentable: visible_debate)
      hidden_debate_comment  = create(:comment, commentable: hidden_debate)

      response = execute("{ comments { edges { node { body } } } }")
      received_comments = extract_fields(response, "comments", "body")

      expect(received_comments).to match_array [visible_debate_comment.body]
    end

    it "does not include comments from hidden polls" do
      visible_poll = create(:poll)
      hidden_poll  = create(:poll, hidden_at: Time.current)

      visible_poll_comment = create(:comment, commentable: visible_poll)
      hidden_poll_comment  = create(:comment, commentable: hidden_poll)

      response = execute("{ comments { edges { node { body } } } }")
      received_comments = extract_fields(response, "comments", "body")

      expect(received_comments).to match_array [visible_poll_comment.body]
    end

    it "does not include comments of debates that are not public" do
      not_public_debate = create(:debate, :hidden)
      not_public_debate_comment = create(:comment, commentable: not_public_debate)
      allow(Comment).to receive(:public_for_api).and_return([])

      response = execute("{ comments { edges { node { body } } } }")
      received_comments = extract_fields(response, "comments", "body")

      expect(received_comments).not_to include(not_public_debate_comment.body)
    end

    it "does not include comments of proposals that are not public" do
      not_public_proposal = create(:proposal)
      not_public_proposal_comment = create(:comment, commentable: not_public_proposal)
      allow(Comment).to receive(:public_for_api).and_return([])

      response = execute("{ comments { edges { node { body } } } }")
      received_comments = extract_fields(response, "comments", "body")

      expect(received_comments).not_to include(not_public_proposal_comment.body)
    end

    it "does not include comments of polls that are not public" do
      not_public_poll = create(:poll)
      not_public_poll_comment = create(:comment, commentable: not_public_poll)
      allow(Comment).to receive(:public_for_api).and_return([])

      response = execute("{ comments { edges { node { body } } } }")
      received_comments = extract_fields(response, "comments", "body")

      expect(received_comments).not_to include(not_public_poll_comment.body)
    end

    it "only returns date and hour for created_at" do
      created_at = Time.zone.parse("2017-12-31 9:30:15")
      create(:comment, created_at: created_at)

      response = execute("{ comments { edges { node { public_created_at } } } }")
      received_timestamps = extract_fields(response, "comments", "public_created_at")

      expect(Time.zone.parse(received_timestamps.first)).to eq Time.zone.parse("2017-12-31 9:00:00")
    end

    it "does not include valuation comments" do
      visible_comment = create(:comment)
      valuation_comment = create(:comment, :valuation)

      response = execute("{ comments { edges { node { body } } } }")
      received_comments = extract_fields(response, "comments", "body")

      expect(received_comments).not_to include(valuation_comment.body)
    end
  end

  describe "Geozones" do
    it "returns geozones" do
      geozone_names = [ create(:geozone), create(:geozone) ].map { |geozone| geozone.name }

      response = execute("{ geozones { edges { node { name } } } }")
      received_names = extract_fields(response, "geozones", "name")

      expect(received_names).to match_array geozone_names
    end
  end

  describe "Proposal notifications" do

    it "does not include proposal notifications for hidden proposals" do
      visible_proposal = create(:proposal)
      hidden_proposal  = create(:proposal, :hidden)

      visible_proposal_notification = create(:proposal_notification, proposal: visible_proposal)
      hidden_proposal_notification  = create(:proposal_notification, proposal: hidden_proposal)

      response = execute("{ proposal_notifications { edges { node { title } } } }")
      received_notifications = extract_fields(response, "proposal_notifications", "title")

      expect(received_notifications).to match_array [visible_proposal_notification.title]
    end

    it "does not include proposal notifications for proposals that are not public" do
      not_public_proposal = create(:proposal)
      not_public_proposal_notification = create(:proposal_notification, proposal: not_public_proposal)
      allow(ProposalNotification).to receive(:public_for_api).and_return([])

      response = execute("{ proposal_notifications { edges { node { title } } } }")
      received_notifications = extract_fields(response, "proposal_notifications", "title")

      expect(received_notifications).not_to include(not_public_proposal_notification.title)
    end

    it "only returns date and hour for created_at" do
      created_at = Time.zone.parse("2017-12-31 9:30:15")
      create(:proposal_notification, created_at: created_at)

      response = execute("{ proposal_notifications { edges { node { public_created_at } } } }")
      received_timestamps = extract_fields(response, "proposal_notifications", "public_created_at")

      expect(Time.zone.parse(received_timestamps.first)).to eq Time.zone.parse("2017-12-31 9:00:00")
    end

    it "only links proposal if public" do
      visible_proposal = create(:proposal)
      hidden_proposal  = create(:proposal, :hidden)

      visible_proposal_notification = create(:proposal_notification, proposal: visible_proposal)
      hidden_proposal_notification  = create(:proposal_notification, proposal: hidden_proposal)

      response = execute("{ proposal_notifications { edges { node { proposal { title } } } } }")
      received_proposals = extract_fields(response, "proposal_notifications", "proposal.title")

      expect(received_proposals).to match_array [visible_proposal.title]
    end

  end

  describe "Tags" do
    it "only display tags with kind nil or category" do
      tag           = create(:tag, name: "Parks")
      category_tag  = create(:tag, :category, name: "Health")
      admin_tag     = create(:tag, name: "Admin tag", kind: "admin")

      proposal = create(:proposal, tag_list: "Parks")
      proposal = create(:proposal, tag_list: "Health")
      proposal = create(:proposal, tag_list: "Admin tag")

      response = execute("{ tags { edges { node { name } } } }")
      received_tags = extract_fields(response, "tags", "name")

      expect(received_tags).to match_array ["Parks", "Health"]
    end

    it "uppercase and lowercase tags work ok together for proposals" do
      create(:tag, name: "Health")
      create(:tag, name: "health")
      create(:proposal, tag_list: "health")
      create(:proposal, tag_list: "Health")

      response = execute("{ tags { edges { node { name } } } }")
      received_tags = extract_fields(response, "tags", "name")

      expect(received_tags).to match_array ["Health", "health"]
    end

    it "uppercase and lowercase tags work ok together for debates" do
      create(:tag, name: "Health")
      create(:tag, name: "health")
      create(:debate, tag_list: "Health")
      create(:debate, tag_list: "health")

      response = execute("{ tags { edges { node { name } } } }")
      received_tags = extract_fields(response, "tags", "name")

      expect(received_tags).to match_array ["Health", "health"]
    end

    it "does not display tags for hidden proposals" do
      proposal = create(:proposal, tag_list: "Health")
      hidden_proposal = create(:proposal, :hidden, tag_list: "SPAM")

      response = execute("{ tags { edges { node { name } } } }")
      received_tags = extract_fields(response, "tags", "name")

      expect(received_tags).to match_array ["Health"]
    end

    it "does not display tags for hidden debates" do
      debate = create(:debate, tag_list: "Health, Transportation")
      hidden_debate = create(:debate, :hidden, tag_list: "SPAM")

      response = execute("{ tags { edges { node { name } } } }")
      received_tags = extract_fields(response, "tags", "name")

      expect(received_tags).to match_array ["Health", "Transportation"]
    end

    xit "does not display tags for proceeding's proposals" do
      valid_proceeding_proposal = create(:proposal, proceeding: "Derechos Humanos", sub_proceeding: "Right to a Home", tag_list: "Health")
      invalid_proceeding_proposal = create(:proposal, tag_list: "Animals")
      invalid_proceeding_proposal.update_attribute("proceeding", "Random")

      response = execute("{ tags { edges { node { name } } } }")
      received_tags = extract_fields(response, "tags", "name")

      expect(received_tags).to match_array ["Health"]
    end

    it "does not display tags for taggings that are not public" do
      proposal = create(:proposal, tag_list: "Health")
      allow(ActsAsTaggableOn::Tag).to receive(:public_for_api).and_return([])

      response = execute("{ tags { edges { node { name } } } }")
      received_tags = extract_fields(response, "tags", "name")

      expect(received_tags).not_to include("Health")
    end

  end

  describe "Votes" do

    it "only returns votes from proposals, debates and comments" do
      proposal = create(:proposal)
      debate   = create(:debate)
      comment  = create(:comment)
      spending_proposal = create(:spending_proposal)

      proposal_vote = create(:vote, votable: proposal)
      debate_vote   = create(:vote, votable: debate)
      comment_vote  = create(:vote, votable: comment)
      spending_proposal_vote = create(:vote, votable: spending_proposal)

      response = execute("{ votes { edges { node { votable_type } } } }")
      received_votables = extract_fields(response, "votes", "votable_type")

      expect(received_votables).to match_array ["Proposal", "Debate", "Comment"]
    end

    it "does not include votes from hidden debates" do
      visible_debate = create(:debate)
      hidden_debate  = create(:debate, :hidden)

      visible_debate_vote = create(:vote, votable: visible_debate)
      hidden_debate_vote  = create(:vote, votable: hidden_debate)

      response = execute("{ votes { edges { node { votable_id } } } }")
      received_debates = extract_fields(response, "votes", "votable_id")

      expect(received_debates).to match_array [visible_debate.id]
    end

    it "does not include votes of hidden proposals" do
      visible_proposal = create(:proposal)
      hidden_proposal  = create(:proposal, hidden_at: Time.current)

      visible_proposal_vote = create(:vote, votable: visible_proposal)
      hidden_proposal_vote  = create(:vote, votable: hidden_proposal)

      response = execute("{ votes { edges { node { votable_id } } } }")
      received_proposals = extract_fields(response, "votes", "votable_id")

      expect(received_proposals).to match_array [visible_proposal.id]
    end

    it "does not include votes of hidden comments" do
      visible_comment = create(:comment)
      hidden_comment  = create(:comment, hidden_at: Time.current)

      visible_comment_vote = create(:vote, votable: visible_comment)
      hidden_comment_vote  = create(:vote, votable: hidden_comment)

      response = execute("{ votes { edges { node { votable_id } } } }")
      received_comments = extract_fields(response, "votes", "votable_id")

      expect(received_comments).to match_array [visible_comment.id]
    end

    it "does not include votes of comments from a hidden proposal" do
      visible_proposal = create(:proposal)
      hidden_proposal  = create(:proposal, :hidden)

      visible_proposal_comment = create(:comment, commentable: visible_proposal)
      hidden_proposal_comment  = create(:comment, commentable: hidden_proposal)

      visible_proposal_comment_vote = create(:vote, votable: visible_proposal_comment)
      hidden_proposal_comment_vote  = create(:vote, votable: hidden_proposal_comment)

      response = execute("{ votes { edges { node { votable_id } } } }")
      received_votables = extract_fields(response, "votes", "votable_id")

      expect(received_votables).to match_array [visible_proposal_comment.id]
    end

    it "does not include votes of comments from a hidden debate" do
      visible_debate = create(:debate)
      hidden_debate  = create(:debate, :hidden)

      visible_debate_comment = create(:comment, commentable: visible_debate)
      hidden_debate_comment  = create(:comment, commentable: hidden_debate)

      visible_debate_comment_vote = create(:vote, votable: visible_debate_comment)
      hidden_debate_comment_vote  = create(:vote, votable: hidden_debate_comment)

      response = execute("{ votes { edges { node { votable_id } } } }")
      received_votables = extract_fields(response, "votes", "votable_id")

      expect(received_votables).to match_array [visible_debate_comment.id]
    end

    it "does not include votes of debates that are not public" do
      not_public_debate = create(:debate)
      allow(Vote).to receive(:public_for_api).and_return([])

      not_public_debate_vote = create(:vote, votable: not_public_debate)

      response = execute("{ votes { edges { node { votable_id } } } }")
      received_votables = extract_fields(response, "votes", "votable_id")

      expect(received_votables).not_to include(not_public_debate.id)
    end

    it "does not include votes of a hidden proposals" do
      not_public_proposal = create(:proposal)
      allow(Vote).to receive(:public_for_api).and_return([])

      not_public_proposal_vote = create(:vote, votable: not_public_proposal)

      response = execute("{ votes { edges { node { votable_id } } } }")
      received_votables = extract_fields(response, "votes", "votable_id")

      expect(received_votables).not_to include(not_public_proposal.id)
    end

    it "does not include votes of a hidden comments" do
      not_public_comment = create(:comment)
      allow(Vote).to receive(:public_for_api).and_return([])

      not_public_comment_vote = create(:vote, votable: not_public_comment)

      response = execute("{ votes { edges { node { votable_id } } } }")
      received_votables = extract_fields(response, "votes", "votable_id")

      expect(received_votables).not_to include(not_public_comment.id)
    end

    it "only returns date and hour for created_at" do
      created_at = Time.zone.parse("2017-12-31 9:30:15")
      create(:vote, created_at: created_at)

      response = execute("{ votes { edges { node { public_created_at } } } }")
      received_timestamps = extract_fields(response, "votes", "public_created_at")

      expect(Time.zone.parse(received_timestamps.first)).to eq Time.zone.parse("2017-12-31 9:00:00")
    end

  end

end
