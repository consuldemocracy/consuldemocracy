class NvoteController < ApplicationController
  #layout "full", only: [:create]
  before_action :authenticate_user!
  skip_authorization_check

  def create
    @poll = Poll.find params[:poll_id]
    @scoped_agora_poll_id = @poll.scoped_agora_poll_id current_user
  end

  def create_token
    election = Poll.find params[:poll_id]
    vote = current_user.get_or_create_vote(election.id)
    message = vote.generate_message
    render content_type: 'text/plain', :status => :ok, :text => "#{vote.generate_hash message}/#{message}"
  end

  def check
    @poll = Poll.find params[:poll_id]
    @scoped_agora_poll_id = @poll.scoped_agora_poll_id(current_user)
  end

end
