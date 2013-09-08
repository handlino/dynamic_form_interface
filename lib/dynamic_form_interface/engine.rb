require 'dynamic_form_interface'
require 'rails'

module DynamicFormInterface
  class Engine < Rails::Engine
    isolate_namespace DynamicFormInterface
  end
end
