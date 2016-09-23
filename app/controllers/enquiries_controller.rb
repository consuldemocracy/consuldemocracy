class EnquiriesController < ApplicationController
  load_and_authorize_resource

  has_filters %w{opened expired incoming}
  has_orders %w{most_voted newest oldest}, only: :show

  def index
    @enquiries = @enquiries.send(@current_filter).sort_for_list.for_render.page(params[:page])
  end

  def show
    @commentable = @enquiry
    @comment_tree = CommentTree.new(@commentable, params[:page], @current_order)
    set_comment_flags(@comment_tree.comments)
  end

end
