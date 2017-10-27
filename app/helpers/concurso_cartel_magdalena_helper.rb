module ConcursoCartelMagdalenaHelper

  def concurso_cartel_class(result)
    if params[:id].split('_').last == result
      'is-active'
    end
  end

end
