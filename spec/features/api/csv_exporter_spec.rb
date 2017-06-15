require 'rails_helper'
require 'csv'

feature 'CSV Exporter' do

  def parse_csv(str)
    CSV.parse(str, col_sep: ';', force_quotes: true, encoding: 'ISO-8859-1')
  end

  background do
    @csv_exporter = API::CSVExporter.new
  end

  context "Proposals" do

    scenario "Attributes" do
      proposal = create(:proposal)

      @csv_exporter.export
      visit csv_path_for("proposals")
      csv = parse_csv(page.html)

      columns = [
        "id",
        "title",
        "description",
        "external_url",
        "cached_votes_up",
        "comments_count",
        "hot_score",
        "confidence_score",
        "created_at",
        "summary",
        "video_url",
        "geozone_id",
        "retired_at",
        "retired_reason",
        "retired_explanation",
        "proceeding",
        "sub_proceeding"]

      expect(csv.first).to eq(columns)
      expect(csv.last).to eq(@csv_exporter.public_attributes(proposal).map(&:to_s))
    end

    scenario "Do not include hidden proposals" do
      visible_proposal = create(:proposal)
      hidden_proposal  = create(:proposal, hidden_at: Time.now)

      @csv_exporter.export
      visit csv_path_for("proposals")
      csv = parse_csv(page.html).flatten

      expect(csv).to include(visible_proposal.title)
      expect(csv).to_not include(hidden_proposal.title)
    end

    scenario "Only include proposals of the Human Rights proceeding" do
      proposal = create(:proposal)
      human_rights_proposal = create(:proposal, proceeding: "Derechos Humanos", sub_proceeding: "Right to have a job")
      other_proceeding_proposal = create(:proposal)
      other_proceeding_proposal.update_attribute(:proceeding, "Another proceeding")

      @csv_exporter.export
      visit csv_path_for("proposals")
      csv = parse_csv(page.html).flatten

      expect(csv).to include(proposal.title)
      expect(csv).to include(human_rights_proposal.title)
      expect(csv).to_not include(other_proceeding_proposal.title)
    end

    scenario "Displays proposals of authors even if public activity is set to false" do
      visible_author = create(:user, public_activity: true)
      hidden_author  = create(:user, public_activity: false)

      visible_proposal = create(:proposal, author: visible_author)
      hidden_proposal  = create(:proposal, author: hidden_author)

      @csv_exporter.export
      visit csv_path_for("proposals")
      csv = parse_csv(page.html).flatten

      expect(csv).to include(visible_proposal.title)
      expect(csv).to include(hidden_proposal.title)
    end

    scenario "Only display date and hour for created_at" do
      created_at = Time.new(2017, 12, 31, 9, 0, 0).in_time_zone(Time.zone)
      create(:proposal, created_at: created_at)

      @csv_exporter.export
      visit csv_path_for("proposals")
      csv = parse_csv(page.html).flatten

      expect(csv).to     include(/#{created_at.strftime("%Y-%m-%d %H")}/)
      expect(csv).to_not include(/#{created_at.strftime("%Y-%m-%d %H:%M")}/)
    end

    scenario "Leave dates other than created_at untouched" do
      created_at = Time.new(2016, 12, 31, 9, 0, 0).in_time_zone(Time.zone)
      retired_at = Time.new(2017, 12, 31, 9, 0, 0).in_time_zone(Time.zone)
      create(:proposal, created_at: created_at, retired_at: retired_at)

      @csv_exporter.export
      visit csv_path_for("proposals")
      csv = parse_csv(page.html).flatten

      expect(csv).to include(/#{created_at.strftime("%Y-%m-%d %H")}/)
      expect(csv).to include(/#{retired_at.strftime("%Y-%m-%d %H:%M")}/)
    end

  end

  context "Debates" do

    scenario "Attributes" do
      debate = create(:debate)

      @csv_exporter.export
      visit csv_path_for("debates")
      csv = parse_csv(page.html)

      columns = [
        "id",
        "title",
        "description",
        "created_at",
        "cached_votes_total",
        "cached_votes_up",
        "cached_votes_down",
        "comments_count",
        "hot_score",
        "confidence_score"]

      expect(csv.first).to eq(columns)
      expect(csv.last).to eq(@csv_exporter.public_attributes(debate).map(&:to_s))
    end

    scenario "Do not include hidden debates" do
      visible_debate = create(:debate)
      hidden_debate  = create(:debate, hidden_at: Time.now)

      @csv_exporter.export
      visit csv_path_for("debates")
      csv = parse_csv(page.html).flatten

      expect(csv).to include(visible_debate.title)
      expect(csv).to_not include(hidden_debate.title)
    end

    scenario "Displays debates of authors even if public activity is set to false" do
      visible_author = create(:user, public_activity: true)
      hidden_author  = create(:user, public_activity: false)

      visible_debate = create(:debate, author: visible_author)
      hidden_debate  = create(:debate, author: hidden_author)

      @csv_exporter.export
      visit csv_path_for("debates")
      csv = parse_csv(page.html).flatten

      expect(csv).to include(visible_debate.title)
      expect(csv).to include(hidden_debate.title)
    end

    scenario "Only display date and hour for created_at" do
      created_at = Time.new(2017, 12, 31, 9, 0, 0).in_time_zone(Time.zone)
      create(:debate, created_at: created_at)

      @csv_exporter.export
      visit csv_path_for("debates")
      csv = parse_csv(page.html).flatten

      expect(csv).to     include(/#{created_at.strftime("%Y-%m-%d %H")}/)
      expect(csv).to_not include(/#{created_at.strftime("%Y-%m-%d %H:%M")}/)
    end

  end

  context "Comments" do

    scenario "Attributes" do
      comment = create(:comment)

      @csv_exporter.export
      visit csv_path_for("comments")
      csv = parse_csv(page.html)

      columns = [
        "id",
        "commentable_id",
        "commentable_type",
        "body",
        "created_at",
        "cached_votes_total",
        "cached_votes_up",
        "cached_votes_down",
        "ancestry",
        "confidence_score"]

      expect(csv.first).to eq(columns)
      expect(csv.last).to eq(@csv_exporter.public_attributes(comment).map(&:to_s))
    end

    scenario "Only include comments from proposals and debates" do
      proposal_comment          = create(:comment, commentable: create(:proposal))
      debate_comment            = create(:comment, commentable: create(:debate))
      spending_proposal_comment = create(:comment, commentable: create(:spending_proposal))

      @csv_exporter.export
      visit csv_path_for("comments")
      csv = parse_csv(page.html).flatten

      expect(csv).to include(proposal_comment.body)
      expect(csv).to include(debate_comment.body)
      expect(csv).to_not include(spending_proposal_comment.body)
    end

    scenario "Displays comments of authors even if public activity is set to false" do
      visible_author = create(:user, public_activity: true)
      hidden_author  = create(:user, public_activity: false)

      visible_comment = create(:comment, user: visible_author)
      hidden_comment  = create(:comment, user: hidden_author)

      @csv_exporter.export
      visit csv_path_for("comments")
      csv = parse_csv(page.html).flatten

      expect(csv).to include(visible_comment.body)
      expect(csv).to include(hidden_comment.body)
    end

    scenario "Do not include hidden comments" do
      visible_comment = create(:comment)
      hidden_comment  = create(:comment, hidden_at: Time.now)

      @csv_exporter.export
      visit csv_path_for("comments")
      csv = parse_csv(page.html).flatten

      expect(csv).to include(visible_comment.body)
      expect(csv).to_not include(hidden_comment.body)
    end

    scenario "Do not include comments from hidden proposals" do
      visible_proposal = create(:proposal)
      hidden_proposal  = create(:proposal, hidden_at: Time.now)

      visible_proposal_comment = create(:comment, commentable: visible_proposal)
      hidden_proposal_comment  = create(:comment, commentable: hidden_proposal)

      @csv_exporter.export
      visit csv_path_for("comments")
      csv = parse_csv(page.html).flatten

      expect(csv).to include(visible_proposal_comment.body)
      expect(csv).to_not include(hidden_proposal_comment.body)
    end

    scenario "Do not include comments from hidden debates" do
      visible_debate = create(:debate)
      hidden_debate  = create(:debate, hidden_at: Time.now)

      visible_debate_comment = create(:comment, commentable: visible_debate)
      hidden_debate_comment  = create(:comment, commentable: hidden_debate)

      @csv_exporter.export
      visit csv_path_for("comments")
      csv = parse_csv(page.html).flatten

      expect(csv).to include(visible_debate_comment.body)
      expect(csv).to_not include(hidden_debate_comment.body)
    end

    scenario "Do not include comments of debates that are not public" do
      not_public_debate = create(:debate, hidden_at: 1.month.ago)
      not_public_debate_comment = create(:comment, commentable: not_public_debate)

      @csv_exporter.export
      visit csv_path_for("comments")
      csv = parse_csv(page.html).flatten

      expect(csv).to_not include(not_public_debate_comment.body)
    end

    scenario "Do not include comments of proposals that are not public" do
      not_public_proposal = create(:proposal, hidden_at: 1.month.ago)
      not_public_proposal_comment = create(:comment, commentable: not_public_proposal)

      @csv_exporter.export
      visit csv_path_for("comments")
      csv = parse_csv(page.html).flatten

      expect(csv).to_not include(not_public_proposal_comment.body)
    end

    scenario "Only display date and hour for created_at" do
      created_at = Time.new(2017, 12, 31, 9, 0, 0).in_time_zone(Time.zone)
      create(:comment, created_at: created_at)

      @csv_exporter.export
      visit csv_path_for("comments")
      csv = parse_csv(page.html).flatten

      expect(csv).to     include(/#{created_at.strftime("%Y-%m-%d %H")}/)
      expect(csv).to_not include(/#{created_at.strftime("%Y-%m-%d %H:%M")}/)
    end

  end

  context "Geozones" do

    scenario "Attributes" do
      geozone = create(:geozone)
      @csv_exporter.export

      visit csv_path_for("geozones")
      csv = parse_csv(page.html)

      columns = ["id", "name"]

      expect(csv.first).to eq(columns)
      expect(csv.last).to eq(@csv_exporter.public_attributes(geozone).map(&:to_s))
    end

  end

  context "Proposal notifications" do

    scenario "Attributes" do
      proposal_notification = create(:proposal_notification)
      @csv_exporter.export

      visit csv_path_for("proposal_notifications")
      csv = parse_csv(page.html)

      columns = [
        "title",
        "body",
        "proposal_id",
        "created_at"]

      expect(csv.first).to eq(columns)
      expect(csv.last).to eq(@csv_exporter.public_attributes(proposal_notification).map(&:to_s))
    end

    scenario "Do not include proposal notifications for hidden proposals" do
      visible_proposal = create(:proposal)
      hidden_proposal  = create(:proposal, hidden_at: Time.now)

      visible_proposal_notification = create(:proposal_notification, proposal: visible_proposal)
      hidden_proposal_notification  = create(:proposal_notification, proposal: hidden_proposal)

      @csv_exporter.export
      visit csv_path_for("proposal_notifications")
      csv = parse_csv(page.html).flatten

      expect(csv).to include(visible_proposal_notification.title)
      expect(csv).to_not include(hidden_proposal_notification.title)
    end

    scenario "Do not include proposal notifications for proposals that are not public" do
      not_public_proposal = create(:proposal, hidden_at: 1.month.ago)
      not_public_proposal_notification = create(:proposal_notification, proposal: not_public_proposal)

      @csv_exporter.export
      visit csv_path_for("proposal_notifications")
      csv = parse_csv(page.html).flatten

      expect(csv).to_not include(not_public_proposal_notification.title)
    end

    scenario "Only display date and hour for created_at" do
      created_at = Time.new(2017, 12, 31, 9, 0, 0).in_time_zone(Time.zone)
      create(:proposal_notification, created_at: created_at)

      @csv_exporter.export
      visit csv_path_for("proposal_notifications")
      csv = parse_csv(page.html).flatten

      expect(csv).to     include(/#{created_at.strftime("%Y-%m-%d %H")}/)
      expect(csv).to_not include(/#{created_at.strftime("%Y-%m-%d %H:%M")}/)
    end

  end

  context "Tags" do

    scenario "Attributes" do
      create(:proposal, tag_list: "Health")

      @csv_exporter.export

      visit csv_path_for("tags")
      csv = parse_csv(page.html)

      columns = [
        "id",
        "name",
        "taggings_count",
        "kind"]

      expect(csv.first).to eq(columns)
      expect(csv.last).to eq(@csv_exporter.public_attributes(Tag.first).map(&:to_s))
    end

    scenario "Only display tags with kind nil or category" do
      tag           = create(:tag, name: "Parks")
      category_tag  = create(:tag, name: "Health",    kind: "category")
      admin_tag     = create(:tag, name: "Admin tag", kind: "admin")

      proposal = create(:proposal, tag_list: "Parks")
      proposal = create(:proposal, tag_list: "Health")
      proposal = create(:proposal, tag_list: "Admin tag")

      @csv_exporter.export

      visit csv_path_for("tags")
      csv = parse_csv(page.html).flatten

      expect(csv).to include("Parks")
      expect(csv).to include("Health")
      expect(csv).to_not include("Admin tag")
    end

    scenario "Uppercase and lowercase tags work ok together for proposals" do
      create(:tag, name: "Health")
      create(:tag, name: "health")
      create(:proposal, tag_list: "health")
      create(:proposal, tag_list: "Health")
      @csv_exporter.export

      visit csv_path_for("tags")
      csv = parse_csv(page.html).flatten

      expect(csv).to include("health")
      expect(csv).to include("Health")
    end

    scenario "Uppercase and lowercase tags work ok together for debates" do
      create(:tag, name: "Health")
      create(:tag, name: "health")
      create(:debate, tag_list: "Health")
      create(:debate, tag_list: "health")
      @csv_exporter.export

      visit csv_path_for("tags")
      csv = parse_csv(page.html).flatten

      expect(csv).to include("health")
      expect(csv).to include("Health")
    end

    scenario "Do not display tags for hidden proposals" do
      proposal = create(:proposal, tag_list: "Health")
      hidden_proposal = create(:proposal, tag_list: "SPAM", hidden_at: Time.now)

      @csv_exporter.export

      visit csv_path_for("tags")
      csv = parse_csv(page.html).flatten

      expect(csv).to include("Health")
      expect(csv).to_not include("SPAM")
    end

    scenario "Do not display tags for hidden debates" do
      debate = create(:debate, tag_list: "Health, Transportation")
      hidden_debate = create(:debate, tag_list: "SPAM", hidden_at: Time.now)

      @csv_exporter.export

      visit csv_path_for("tags")
      csv = parse_csv(page.html).flatten

      expect(csv).to include("Health")
      expect(csv).to_not include("SPAM")
    end

    scenario "Do not display tags for proceeding's proposals" do
      valid_proceeding_proposal = create(:proposal, proceeding: "Derechos Humanos", sub_proceeding: "Right to a Home", tag_list: "Health")
      invalid_proceeding_proposal = create(:proposal, tag_list: "Animals")
      invalid_proceeding_proposal.update_attribute('proceeding', "Random")

      @csv_exporter.export

      visit csv_path_for("tags")
      csv = parse_csv(page.html).flatten

      expect(csv).to include("Health")
      expect(csv).to_not include("Animals")
    end

    scenario "Do not display tags for taggings that are not public" do
      create(:tag, name: 'Special', kind: 'special')
      create(:tag, name: 'Category', kind: 'category')
      create(:proposal, tag_list: "Hidden", hidden_at: 1.month.ago)
      create(:proposal, tag_list: "Ok")
      create(:proposal, tag_list: "Special")
      create(:proposal, tag_list: "Category")
      create(:spending_proposal, tag_list: "NotPorD")

      @csv_exporter.export

      visit csv_path_for("tags")
      csv = parse_csv(page.html).flatten

      expect(csv).to_not include("Hidden") # Used only on a hidden proposal
      expect(csv).to include("Ok") # Used on a public proposal, nil kind
      expect(csv).to_not include("Special") # Used on a public proposal, special kind
      expect(csv).to include("Category") # Used on a public proposal, category kind
      expect(csv).to_not include("NotPorD") # Not used on proposals or debates
    end

  end

  context "Taggings" do

    scenario "Attributes" do
      tagging = create(:tagging)
      @csv_exporter.export

      visit csv_path_for("taggings")
      csv = parse_csv(page.html)

      columns = [
        "tag_id",
        "taggable_id",
        "taggable_type"]

      expect(csv.first).to eq(columns)
      expect(csv.last).to eq(@csv_exporter.public_attributes(tagging).map(&:to_s))
    end

    scenario "Only include taggings for proposals and debates" do
      proposal          = create(:proposal)
      debate            = create(:debate)
      spending_proposal = create(:spending_proposal)

      proposal_tagging          = create(:tagging, taggable: proposal)
      debate_tagging            = create(:tagging, taggable: debate)
      spending_proposal_tagging = create(:tagging, taggable: spending_proposal)

      @csv_exporter.export

      visit csv_path_for("taggings")
      csv = parse_csv(page.html).flatten

      expect(csv).to include(proposal_tagging.taggable_type)
      expect(csv).to include(debate_tagging.taggable_type)
      expect(csv).to_not include(spending_proposal_tagging.taggable_type)
    end

    scenario "Do not include taggings for hidden debates" do
      visible_debate = create(:debate)
      hidden_debate = create(:debate, hidden_at: Time.now)

      visible_debate_tagging = create(:tagging, taggable: visible_debate)
      hidden_debate_tagging  = create(:tagging, taggable: hidden_debate)

      @csv_exporter.export

      visit csv_path_for("taggings")
      csv = parse_csv(page.html)

      taggable_ids = csv.collect {|element| element[1]}

      expect(taggable_ids).to include(visible_debate_tagging.taggable_id.to_s)
      expect(taggable_ids).to_not include(hidden_debate_tagging.taggable_id.to_s)
    end

    scenario "Do not include taggings for hidden proposals" do
      visible_proposal = create(:proposal)
      hidden_proposal  = create(:proposal, hidden_at: Time.now)

      visible_proposal_tagging = create(:tagging, taggable: visible_proposal)
      hidden_proposal_tagging  = create(:tagging, taggable: hidden_proposal)

      @csv_exporter.export

      visit csv_path_for("taggings")
      csv = parse_csv(page.html)

      taggable_ids = csv.collect {|element| element[1]}

      expect(taggable_ids).to include(visible_proposal_tagging.taggable_id.to_s)
      expect(taggable_ids).to_not include(hidden_proposal_tagging.taggable_id.to_s)
    end

    scenario "Only display tagging for a tag kind nil or category" do
      category_tag  = create(:tag, name: "Health",    kind: "category")
      admin_tag     = create(:tag, name: "Admin tag", kind: "admin")

      visible_tag_tagging = create(:tagging, tag: category_tag, taggable: create(:proposal))
      hidden_tag_tagging  = create(:tagging, tag: admin_tag, taggable: create(:debate))

      @csv_exporter.export

      visit csv_path_for("taggings")
      csv = parse_csv(page.html).flatten

      expect(csv).to include(visible_tag_tagging.taggable_type)
      expect(csv).to_not include(hidden_tag_tagging.taggable_type)
    end

    scenario "Do not include taggings for proposals that are not public" do
      not_public_proposal = create(:proposal, hidden_at: 1.month.ago)
      not_public_proposal_tagging = create(:tagging, taggable: not_public_proposal)

      @csv_exporter.export

      visit csv_path_for("taggings")
      csv = parse_csv(page.html)

      taggable_ids = csv.collect {|element| element[1]}

      expect(taggable_ids).to_not include(not_public_proposal_tagging.taggable_id.to_s)
    end

    scenario "Do not include taggings for debates that are not public" do
      not_public_debate = create(:debate, hidden_at: 1.month.ago)
      not_public_debate_tagging = create(:tagging, taggable: not_public_debate)

      @csv_exporter.export

      visit csv_path_for("taggings")
      csv = parse_csv(page.html)

      taggable_ids = csv.collect {|element| element[1]}

      expect(taggable_ids).to_not include(not_public_debate_tagging.taggable_id.to_s)
    end

  end

  context "Votes" do

    scenario "Attributes" do
      vote = create(:vote)
      @csv_exporter.export

      visit csv_path_for("votes")
      csv = parse_csv(page.html)

      columns = [
        "votable_id",
        "votable_type",
        "vote_flag",
        "created_at"]

      expect(csv.first).to eq(columns)
      expect(csv.last).to eq(@csv_exporter.public_attributes(vote).map(&:to_s))
    end

    scenario "Only include votes from proposals, debates and comments" do
      proposal = create(:proposal)
      debate   = create(:debate)
      comment  = create(:comment)
      spending_proposal = create(:spending_proposal)

      proposal_vote = create(:vote, votable: proposal)
      debate_vote   = create(:vote, votable: debate)
      comment_vote  = create(:vote, votable: comment)
      spending_proposal_vote = create(:vote, votable: spending_proposal)

      @csv_exporter.export
      visit csv_path_for("votes")
      csv = parse_csv(page.html).flatten

      expect(csv).to include(proposal_vote.votable_type)
      expect(csv).to include(debate_vote.votable_type)
      expect(csv).to include(comment_vote.votable_type)
      expect(csv).to_not include(spending_proposal_vote.votable_type)
    end

    scenario "Do not include votes of a hidden debates" do
      visible_debate = create(:debate)
      hidden_debate  = create(:debate, hidden_at: Time.now)

      visible_debate_vote = create(:vote, votable: visible_debate)
      hidden_debate_vote  = create(:vote, votable: hidden_debate)

      @csv_exporter.export
      visit csv_path_for("votes")
      csv = parse_csv(page.html)

      votable_ids = csv.collect {|element| element[0]}

      expect(votable_ids).to include(visible_debate_vote.votable_id.to_s)
      expect(votable_ids).to_not include(hidden_debate_vote.votable_id.to_s)
    end

    scenario "Do not include votes of a hidden proposals" do
      visible_proposal = create(:proposal)
      hidden_proposal  = create(:proposal, hidden_at: Time.now)

      visible_proposal_vote = create(:vote, votable: visible_proposal)
      hidden_proposal_vote  = create(:vote, votable: hidden_proposal)

      @csv_exporter.export
      visit csv_path_for("votes")
      csv = parse_csv(page.html)

      votable_ids = csv.collect {|element| element[0]}

      expect(votable_ids).to include(visible_proposal_vote.votable_id.to_s)
      expect(votable_ids).to_not include(hidden_proposal_vote.votable_id.to_s)
    end

    scenario "Do not include votes of a hidden comments" do
      visible_comment = create(:comment)
      hidden_comment  = create(:comment, hidden_at: Time.now)

      visible_comment_vote = create(:vote, votable: visible_comment)
      hidden_comment_vote  = create(:vote, votable: hidden_comment)

      @csv_exporter.export
      visit csv_path_for("votes")
      csv = parse_csv(page.html)

      votable_ids = csv.collect {|element| element[0]}

      expect(votable_ids).to include(visible_comment_vote.votable_id.to_s)
      expect(votable_ids).to_not include(hidden_comment_vote.votable_id.to_s)
    end

    scenario "Do not include votes of comments from a hidden proposal" do
      visible_proposal = create(:proposal)
      hidden_proposal  = create(:proposal, hidden_at: Time.now)

      visible_proposal_comment = create(:comment, commentable: visible_proposal)
      hidden_proposal_comment  = create(:comment, commentable: hidden_proposal)

      visible_proposal_comment_vote = create(:vote, votable: visible_proposal_comment)
      hidden_proposal_comment_vote  = create(:vote, votable: hidden_proposal_comment)

      @csv_exporter.export
      visit csv_path_for("votes")
      csv = parse_csv(page.html)

      votable_ids = csv.collect {|element| element[0]}

      expect(votable_ids).to include(visible_proposal_comment_vote.votable_id.to_s)
      expect(votable_ids).to_not include(hidden_proposal_comment_vote.votable_id.to_s)
    end

    scenario "Do not include votes of comments from a hidden debate" do
      visible_debate = create(:debate)
      hidden_debate  = create(:debate, hidden_at: Time.now)

      visible_debate_comment = create(:comment, commentable: visible_debate)
      hidden_debate_comment  = create(:comment, commentable: hidden_debate)

      visible_debate_comment_vote = create(:vote, votable: visible_debate_comment)
      hidden_debate_comment_vote  = create(:vote, votable: hidden_debate_comment)

      @csv_exporter.export
      visit csv_path_for("votes")
      csv = parse_csv(page.html)

      votable_ids = csv.collect {|element| element[0]}

      expect(votable_ids).to include(visible_debate_comment_vote.votable_id.to_s)
      expect(votable_ids).to_not include(hidden_debate_comment_vote.votable_id.to_s)
    end

    scenario "Do not include votes of debates that are not public" do
      not_public_debate = create(:debate, hidden_at: 1.month.ago)
      not_public_debate_vote = create(:vote, votable: not_public_debate)

      @csv_exporter.export
      visit csv_path_for("votes")
      csv = parse_csv(page.html)

      votable_ids = csv.collect {|element| element[0]}

      expect(votable_ids).to_not include(not_public_debate_vote.votable_id.to_s)
    end

    scenario "Do not include votes of a hidden proposals" do
      not_public_proposal = create(:proposal, hidden_at: 1.month.ago)
      not_public_proposal_vote = create(:vote, votable: not_public_proposal)

      @csv_exporter.export
      visit csv_path_for("votes")
      csv = parse_csv(page.html)

      votable_ids = csv.collect {|element| element[0]}

      expect(votable_ids).to_not include(not_public_proposal_vote.votable_id.to_s)
    end

    scenario "Do not include votes of a hidden comments" do
      not_public_comment = create(:comment, hidden_at: 1.month.ago)
      not_public_comment_vote = create(:vote, votable: not_public_comment)

      @csv_exporter.export
      visit csv_path_for("votes")
      csv = parse_csv(page.html)

      votable_ids = csv.collect {|element| element[0]}

      expect(votable_ids).to_not include(not_public_comment_vote.votable_id.to_s)
    end

    scenario "Only display date and hour for created_at" do
      created_at = Time.new(2017, 12, 31, 9, 0, 0).in_time_zone(Time.zone)
      create(:vote, created_at: created_at)

      @csv_exporter.export
      visit csv_path_for("votes")
      csv = parse_csv(page.html).flatten

      expect(csv).to     include(/#{created_at.strftime("%Y-%m-%d %H")}/)
      expect(csv).to_not include(/#{created_at.strftime("%Y-%m-%d %H:%M")}/)
    end

  end
end
