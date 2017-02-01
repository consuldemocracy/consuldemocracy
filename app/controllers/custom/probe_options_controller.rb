class ProbeOptionsController < ApplicationController
  skip_authorization_check

  before_action :load_probe
  before_action :load_probe_option, only: [:show, :discard]
  before_action :load_user_selection, only: [:show]

  has_orders %w{most_voted newest oldest}, only: :show

  def show
    @commentable = @probe_option
    @comment_tree = CommentTree.new(@commentable, params[:page], @current_order)
    set_comment_flags(@comment_tree.comments)

    render "probe_options/#{@probe.codename}/show"
  end

  def discard
    (session[:discarded_probe_option_ids] ||= [] ) << @probe_option.id
  end

  def restore_discarded
    session[:discarded_probe_option_ids] = nil
  end

  private

    def load_probe
      @probe = Probe.find_by! codename: params[:probe_id]
    end

    def load_probe_option
      @probe_option = @probe.probe_options.find(params[:id])
    end

    def load_user_selection
      @user_selection = @probe.option_voted_by(current_user) if current_user
    end

end
