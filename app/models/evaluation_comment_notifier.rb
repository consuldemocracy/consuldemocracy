class EvaluationCommentNotifier
  def initialize(args = {})
    @comment = args.fetch(:comment)
  end

  def process
    send_evaluation_comment_email
  end

  private

    def send_evaluation_comment_email
      EvaluationCommentEmail.new(@comment).to.each do |to|
        Mailer.evaluation_comment(@comment, to).deliver_later
      end
    end
end
