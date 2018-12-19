class HumanRightsController < ApplicationController
  skip_authorization_check

  include CommentableActions
  include RandomSeed

  before_action :set_random_seed,             only: :index
  before_action :parse_search_terms,          only: :index
  before_action :parse_advanced_search_terms, only: :index
  before_action :set_search_order,            only: :index

  has_orders %w{random confidence_score},     only: :index
  has_orders %w{most_voted newest oldest},    only: :show

  def index
    load_human_right_proposals
    filter_by_search
    filter_by_subproceeding

    load_votes
    load_tags
    load_subproceedings

    paginate_results
    order_results
    render "proposals/index"
  end

  def show
    @proposal = Proposal.find(params[:id])
    set_resource_votes(@proposal)

    @notifications = []

    @commentable = @proposal
    @comment_tree = CommentTree.new(@commentable, params[:page], @current_order)

    set_comment_flags(@comment_tree.comments)
    render "proposals/show"
  end

  private

  def load_human_right_proposals
    @proposals = @human_right_proposals = Proposal.where(proceeding: "Derechos Humanos")
  end

  def filter_by_search
    @proposals = @search_terms.present? ? @proposals.search(@search_terms) : @proposals
    @proposals = @advanced_search_terms.present? ? @proposals.filter(@advanced_search_terms) : @proposals
  end

  def filter_by_subproceeding
    @proposals = @proposals.where("sub_proceeding = ?", params[:sub_proceeding]) if params[:sub_proceeding].present?
  end

  def load_votes
    set_resource_votes(@proposals)
  end

  def load_tags
    @tag_cloud = tag_cloud
  end

  def load_subproceedings
    @subproceedings = @human_right_proposals.distinct.pluck(:sub_proceeding)
                                            .select { |sub_proceeding| official_human_rights_subproceedings.include?(sub_proceeding) }.sort
  end

  def paginate_results
    @proposals = @proposals.page(params[:page])
  end

  def order_results
    if @current_order == "random"
      @proposals = @proposals.sort_by_random(session[:random_seed])
    else
      @proposals = @proposals.send("sort_by_#{@current_order}")
    end
  end

  def resource_name
    "proposal"
  end

  def resource_model
    Proposal
  end

  def official_human_rights_subproceedings
    ["Conocer y defender mejor mis derechos",
     "Derecho a la participación ciudadana en el diseño, ejecución y evaluación de las políticas",
     "Derecho al acceso a la información de las administraciones públicas",
     "Libertad de expresión, reunión, asociación y manifestación",
     "Derecho a la verdad, justicia y reparación para víctimas de crímenes internacionales (incluidas las víctimas del ,franquismo)",
     "Derecho a una vida sin violencia machista",
     "Derecho a contar con una policía municipal democrática y eficaz",
     "Derecho a la salud, incluida la salud sexual y reproductiva",
     "Derecho a la vivienda",
     "Derecho al trabajo digno",
     "Derecho a la educación",
     "Derecho a la cultura",
     "Derecho al cuidado, incluyendo los derechos de las personas cuidadoras",
     "Derecho de las mujeres a la no discriminación",
     "Derecho de las personas gays, lesbianas, transexuales, bisexuales e intersexuales a la no discriminación",
     "Derecho a no sufrir racismo y derechos de las personas migrantes y refugiadas",
     "Derechos de la infancia",
     "Derechos de las personas con diversidad funcional",
     "Derecho a la alimentación y al agua de calidad",
     "Derecho a la movilidad y el buen transporte en la ciudad",
     "Derecho al desarrollo urbano sostenible",
     "Contribución a las defensa de los derechos humanos en el mundo (cooperación)"]
  end

end
