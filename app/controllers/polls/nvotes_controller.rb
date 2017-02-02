class Polls::NvotesController < ApplicationController
  before_action :authenticate_user!, except: :success
  skip_before_action :verify_authenticity_token, only: [:success]
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

  def success
    authorization_hash = request.headers["Authorization"]

    authorization_hash.gsub!("khmac:///sha-256;", "")
    signature, message = authorization_hash.split("/")

    message_parts = message.split(":")
    voter_hash = message_parts[0]
    nvotes_poll_id = message_parts[2]

    nvote = Poll::Nvote.where(voter_hash: voter_hash).first
    poll = Poll.where(nvotes_poll_id: nvotes_poll_id).first

    if nvote && poll
      Poll::Voter.create!(user: nvote.user, poll: poll)
    end

    render content_type: 'text/plain', status: :ok, text: ""
  end

end
