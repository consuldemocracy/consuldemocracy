class NvoteController < ApplicationController
  before_action :authenticate_user!
  skip_authorization_check

  def new
    @poll = Poll.find(params[:poll_id])
  end

  def token
    poll = Poll.find(params[:poll_id])
    vote = current_user.get_or_create_nvote(poll)
    message = vote.generate_message
    render content_type: 'text/plain', status: :ok, text: "#{vote.generate_hash message}/#{message}"
  end

  #Agora Callback
  def success
  end

end
