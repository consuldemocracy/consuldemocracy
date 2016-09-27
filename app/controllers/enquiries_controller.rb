class EnquiriesController < ApplicationController
  load_and_authorize_resource

  has_filters %w{opened expired incoming}
  has_orders %w{most_voted newest oldest}, only: :show

  def index
    @enquiries = @enquiries.send(@current_filter).sort_for_list.for_render.page(params[:page])
  end

  def show
    @commentable = @enquiry.proposal.present? ? @enquiry.proposal : @enquiry
    @comment_tree = CommentTree.new(@commentable, params[:page], @current_order)
    set_comment_flags(@comment_tree.comments)
    @enquiry_answer = @enquiry.answers.where(author_id: current_user.try(:id)).first
  end

  def answer
    @enquiry_answer = @enquiry.answers.find_or_initialize_by(author_id: current_user.id)
    @enquiry_answer.answer = params[:answer]
    @enquiry_answer.save
  end

end
