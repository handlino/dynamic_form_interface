module DynamicFormInterface
  module Generators
    class MigrationGenerator < Rails::Generators::Base
      include Rails::Generators::Migration
      source_root File.expand_path('../templates', __FILE__)
      desc "add DynamicFormInterface DB migration file"
      hook_for :orm, :as => :dynamic_form_interface

    end
  end
end
