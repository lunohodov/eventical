module ApplicationHelper
  def body_class
    qualified_name = controller.controller_path.gsub("/", "-")
    "#{qualified_name} #{qualified_name}-#{controller.action_name}"
  end
end
