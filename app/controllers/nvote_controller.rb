class NvoteController < ApplicationController
  before_action :authenticate_user!
  skip_authorization_check

  def create
    @poll = Poll.find(params[:poll_id])
  end

  def create_token
    poll = Poll.find(params[:poll_id])
    vote = current_user.get_or_create_vote(poll)
    message = vote.generate_message
    render content_type: 'text/plain', status: :ok, text: "#{vote.generate_hash message}/#{message}"
  end

end
