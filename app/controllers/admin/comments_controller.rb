class Admin::CommentsController < Admin::BaseController

  include DownloadSettingsHelper

  def index
    @comments = Comment.sort_by_newest.page(params[:page])

    respond_to do |format|
      format.html
      format.csv {send_data to_csv(Comment.sort_by_newest, Comment),
                            type: "text/csv",
                            disposition: "attachment",
                            filename: "comments.csv" }
    end
  end

end
