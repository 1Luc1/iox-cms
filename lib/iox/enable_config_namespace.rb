Rails::Application::Configuration.class_eval do
  def iox
    @iox ||= ActiveSupport::OrderedOptions.new
  end
end