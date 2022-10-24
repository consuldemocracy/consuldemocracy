class Dashboard::PosterController < Dashboard::BaseController
  def index
    authorize! :manage_poster, proposal

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "poster",
               page_size: "A4",
               dpi: 300,
               zoom: 0.32,
               show_as_html: Rails.env.test? || params.key?("debug"),
               margin:  { top: 0 }
      end
    end
  end

  def new
    authorize! :manage_poster, proposal
  end
end
