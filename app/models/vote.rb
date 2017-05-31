class Vote < ActsAsVotable::Vote

  include Graphqlable

  def self.public_for_api
    joins("FULL OUTER JOIN debates ON votable_type = 'Debate' AND votable_id = debates.id").
    joins("FULL OUTER JOIN proposals ON votable_type = 'Proposal' AND votable_id = proposals.id").
    joins("FULL OUTER JOIN comments ON votable_type = 'Comment' AND votable_id = comments.id").
    where("(votable_type = 'Proposal' AND proposals.hidden_at IS NULL) OR      \
           (votable_type = 'Debate'   AND debates.hidden_at   IS NULL) OR      \
           (                                                                   \
             (votable_type = 'Comment'  AND comments.hidden_at IS NULL) AND    \
             (                                                                 \
               (comments.commentable_type = 'Proposal' AND (comments.commentable_id IN (SELECT id FROM proposals WHERE hidden_at IS NULL GROUP BY id))) OR \
               (comments.commentable_type = 'Debate'   AND (comments.commentable_id IN (SELECT id FROM debates   WHERE hidden_at IS NULL GROUP BY id)))    \
             )                                                                 \
           )")
  end
end
