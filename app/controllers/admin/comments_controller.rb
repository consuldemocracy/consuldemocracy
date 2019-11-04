class Admin::CommentsController < Admin::BaseController
  include SendCsvData

  def index
    respond_to do |format|
      format.html { @comments = Comment.sort_by_newest.page(params[:page]) }
      format.csv { send_csv_data Comment.sort_by_newest }
    end
  end
end
