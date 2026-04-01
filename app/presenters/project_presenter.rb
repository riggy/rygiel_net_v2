class ProjectPresenter < SimpleDelegator
  def initialize(project)
    @project = project
    super
  end

  def chatbot_context
    "- **#{name}**: #{description} (#{tag_list.join(', ')})"
  end
end
