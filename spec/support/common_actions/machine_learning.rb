# spec/support/common_actions/machine_learning.rb
module MachineLearningActions
  def enable_machine_learning
    Setting["feature.machine_learning"] = true
    Setting["machine_learning.tags"] = true
    Setting["machine_learning.related_content"] = true
    Setting["machine_learning.comments_summary"] = true
    allow(MachineLearning).to receive(:enabled?).and_return(true)
  end
end
