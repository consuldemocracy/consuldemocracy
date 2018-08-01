class Dashboard::PosterController < Dashboard::BaseController
  def index
    authorize! :manage_poster, proposal

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: 'poster', page_size: 'A3', show_as_html: Rails.env.test?
      end
    end
  end

  def new
    authorize! :manage_poster, proposal
  end
end
