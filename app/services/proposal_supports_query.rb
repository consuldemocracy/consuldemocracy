# frozen_string_literal: true

class ProposalSupportsQuery
  attr_reader :params

  def self.for(params)
    query = ProposalSupportsQuery.new params
    query.results
  end

  def initialize(params)
    @params = params
  end

  def results
    grouped_votes = groups
    grouped_votes.each do |group, votes|
      grouped_votes[group] = votes.inject(0) { |sum, vote| sum + vote.vote_weight }
    end

    grouped_votes
  end

  private

  def groups
    return votes.group_by { |v| v.created_at.to_date.year } if params[:group_by] == 'year'
    return votes.group_by { |v| "#{v.created_at.to_date.cweek}/#{v.created_at.to_date.year}" } if params[:group_by] == 'week'
    return votes.group_by { |v| "#{v.created_at.to_date.year}-#{v.created_at.to_date.month}" } if params[:group_by] == 'month'
    votes.group_by { |v| v.created_at.to_date }
  end

  def votes
    Vote.where(votable: proposal, created_at: start_date..end_date).order(created_at: :asc)
  end

  def proposal
    @proposal ||= Proposal.find(params[:proposal_id])
  end

  def start_date
    return Date.parse(params[:start_date]) unless params[:start_date].blank?
    proposal.created_at.to_date
  end

  def end_date
    return Date.parse(params[:end_date]) unless params[:end_date].blank?
    Date.today
  end
end
