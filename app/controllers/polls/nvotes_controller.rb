class Polls::NvotesController < ApplicationController
  before_action :authenticate_user!
  skip_authorization_check

  def new
    @poll = Poll.find(params[:poll_id])
  end

  def token
    poll = Poll.find(params[:poll_id])
    nvote = current_user.get_or_create_nvote(poll)
    message = nvote.generate_message
    render content_type: 'text/plain', status: :ok, text: "#{nvote.generate_hash message}/#{message}"
  end

  #Agora Callback
  def success
  end

end
