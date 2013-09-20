Rails::Application::Configuration.class_eval do
  def ion
    @ion ||= ActiveSupport::OrderedOptions.new
  end
end