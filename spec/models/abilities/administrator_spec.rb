require 'rails_helper'
require 'cancan/matchers'

describe "Abilities::Administrator" do
  subject(:ability) { Ability.new(user) }
  let(:user) { administrator.user }
  let(:administrator) { create(:administrator) }

  let(:other_user) { create(:user) }
  let(:hidden_user) { create(:user, :hidden) }

  let(:debate) { create(:debate) }
  let(:comment) { create(:comment) }
  let(:proposal) { create(:proposal) }
  let(:budget_investment) { create(:budget_investment) }
  let(:legislation_question) { create(:legislation_question) }
  let(:poll_question) { create(:poll_question) }

  let(:proposal_document) { build(:document, documentable: proposal) }
  let(:budget_investment_document) { build(:document, documentable: budget_investment) }
  let(:poll_question_document) { build(:document, documentable: poll_question) }

  let(:proposal_image) { build(:image, imageable: proposal) }
  let(:budget_investment_image) { build(:image, imageable: budget_investment) }

  let(:hidden_debate) { create(:debate, :hidden) }
  let(:hidden_comment) { create(:comment, :hidden) }
  let(:hidden_proposal) { create(:proposal, :hidden) }

  it { should be_able_to(:index, Debate) }
  it { should be_able_to(:show, debate) }
  it { should be_able_to(:vote, debate) }

  it { should be_able_to(:index, Proposal) }
  it { should be_able_to(:show, proposal) }

  it { should_not be_able_to(:restore, comment) }
  it { should_not be_able_to(:restore, debate) }
  it { should_not be_able_to(:restore, proposal) }
  it { should_not be_able_to(:restore, other_user) }

  it { should be_able_to(:restore, hidden_comment) }
  it { should be_able_to(:restore, hidden_debate) }
  it { should be_able_to(:restore, hidden_proposal) }
  it { should be_able_to(:restore, hidden_user) }

  it { should_not be_able_to(:confirm_hide, comment) }
  it { should_not be_able_to(:confirm_hide, debate) }
  it { should_not be_able_to(:confirm_hide, proposal) }
  it { should_not be_able_to(:confirm_hide, other_user) }

  it { should be_able_to(:confirm_hide, hidden_comment) }
  it { should be_able_to(:confirm_hide, hidden_debate) }
  it { should be_able_to(:confirm_hide, hidden_proposal) }
  it { should be_able_to(:confirm_hide, hidden_user) }

  it { should be_able_to(:comment_as_administrator, debate) }
  it { should_not be_able_to(:comment_as_moderator, debate) }

  it { should be_able_to(:comment_as_administrator, proposal) }
  it { should_not be_able_to(:comment_as_moderator, proposal) }

  it { should be_able_to(:comment_as_administrator, legislation_question) }
  it { should_not be_able_to(:comment_as_moderator, legislation_question) }

  it { should be_able_to(:manage, Annotation) }

  it { should be_able_to(:read, SpendingProposal) }
  it { should be_able_to(:update, SpendingProposal) }
  it { should be_able_to(:valuate, SpendingProposal) }
  it { should be_able_to(:destroy, SpendingProposal) }

  it { should be_able_to(:create, Budget) }
  it { should be_able_to(:update, Budget) }
  it { should be_able_to(:read_results, Budget) }

  it { should be_able_to(:create, Budget::ValuatorAssignment) }

  it { should be_able_to(:update, Budget::Investment) }
  it { should be_able_to(:hide,   Budget::Investment) }

  it { should be_able_to(:valuate, create(:budget_investment, budget: create(:budget, phase: 'valuating'))) }
  it { should be_able_to(:valuate, create(:budget_investment, budget: create(:budget, phase: 'finished'))) }

  it { should be_able_to(:destroy, proposal_document) }
  it { should be_able_to(:destroy, budget_investment_document) }
  it { should be_able_to(:destroy, poll_question_document) }

  it { should be_able_to(:destroy, proposal_image) }
  it { should be_able_to(:destroy, budget_investment_image) }

end
