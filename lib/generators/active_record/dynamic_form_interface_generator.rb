require 'rails/generators/active_record'
module ActiveRecord
  module Generators

    class DynamicFormInterfaceGenerator < Rails::Generators::Base
      include Rails::Generators::Migration
      source_root File.expand_path('../templates', __FILE__)

      def create_migratation
        migration_template "create_dynamic_form_interface_table.rb", "db/migrate/create_dynamic_form_interface_table.rb"
      end
      private
      def self.next_migration_number(dirname)
        if ActiveRecord::Base.timestamped_migrations
          Time.now.utc.strftime("%Y%m%d%H%M%S")
        else
          "%.3d" % (current_migration_number(dirname) + 1)
        end 
      end 

    end
  end
end
