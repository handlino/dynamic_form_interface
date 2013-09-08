class CreateDynamicFormInterfaceTable < ActiveRecord::Migration
  def self.up

    create_table "dynamic_form_interface_custom_file_values", :force => true do |t|
      t.integer  "form_field_id"
      
      t.references :form, :polymorphic => true     
      t.references :applicant, :polymorphic => true 

      t.string    :asset
      t.integer   :asset_size

      t.timestamps
    end

    add_index "dynamic_form_interface_custom_file_values", ["form_field_id"], :name => "dynamic_form_interface_custom_file_values_form_field_id"
    add_index "dynamic_form_interface_custom_file_values", ["applicant_id","applicant_type"], :name => "dynamic_form_interface_custom_file_values_applicant"
    add_index "dynamic_form_interface_custom_file_values", ["form_id","form_type"], :name => "dynamic_form_interface_custom_file_values_form"

    create_table "dynamic_form_interface_custom_option_values", :force => true do |t|
      t.integer  "form_field_id"
      t.references :form, :polymorphic => true     
      t.references :applicant, :polymorphic => true 

      t.integer  "custom_option_id"
      t.string   "comment" 
      t.timestamps
    end

    add_index "dynamic_form_interface_custom_option_values", ["form_id","form_type"], :name => "dynamic_form_interface_custom_option_values_form"
    add_index "dynamic_form_interface_custom_option_values", ["applicant_id","applicant_type"], :name => "dynamic_form_interface_custom_option_values_applicant"
    add_index "dynamic_form_interface_custom_option_values", ["form_field_id"], :name => "dynamic_form_interface_custom_option_values_form_field_id"

    create_table "dynamic_form_interface_custom_options", :force => true do |t|
      t.integer  "form_field_id"
      t.integer  "position"
      t.string   "name"
      t.boolean :commentable, :default => false
      t.timestamps
    end
    add_index "dynamic_form_interface_custom_options", ["form_field_id"], :name => "dynamic_form_interface_custom_options_form_field_id"


    create_table "dynamic_form_interface_custom_string_values", :force => true do |t|
      t.integer  "form_field_id"
      t.references :form, :polymorphic => true     
      t.references :applicant, :polymorphic => true 
      t.string   "value"
      t.timestamps
    end

    add_index "dynamic_form_interface_custom_string_values", ["form_id","form_type"], :name => "dynamic_form_interface_custom_string_values_form"
    add_index "dynamic_form_interface_custom_string_values", ["applicant_id","applicant_type"], :name => "dynamic_form_interface_custom_string_values_applicant"
    add_index "dynamic_form_interface_custom_string_values", ["form_field_id"], :name => "dynamic_form_interface_custom_string_values_form_field_id"

    create_table "dynamic_form_interface_custom_text_values", :force => true do |t|
      t.integer  "form_field_id"
      t.references :form, :polymorphic => true     
      t.references :applicant, :polymorphic => true 
      t.text     "value"
      t.timestamps
    end

    add_index "dynamic_form_interface_custom_text_values", ["form_id","form_type"], :name => "dynamic_form_interface_custom_text_values_form"
    add_index "dynamic_form_interface_custom_text_values", ["applicant_id","applicant_type"], :name => "dynamic_form_interface_custom_text_values_applicant"
    add_index "dynamic_form_interface_custom_text_values", ["form_field_id"], :name => "dynamic_form_interface_custom_text_values_form_field_id"

    create_table "dynamic_form_interface_form_fields", :force => true do |t|
      t.references :form, :polymorphic => true     
      t.integer "position"
      t.string  "type"
      t.string  "title"
      t.text    "description"
      t.boolean "is_required",       :default => false
      t.integer "rows"
      t.integer "cols"
      t.integer "size"
      t.integer "default_option_id", :default => 0
      t.string  "default_field"
      t.boolean "updateable", :default => true
      t.boolean "destroyable", :default => true
      t.boolean "renameable", :default => true
    end

    add_index "dynamic_form_interface_form_fields", ["form_id", "form_type"], :name => "dynamic_form_interface_form_fields_form"

    create_table "dynamic_form_interface_form_field_translations", :force => true do |t|
      t.references :resource, :polymorphic => true     
      t.string   "locale"
      t.string   "attribute_name"
      t.string   "string_value"
      t.text     "text_value"

      t.timestamps
    end
    add_index "dynamic_form_interface_form_field_translations", ["resource_id","resource_type"], :name => "dynamic_form_interface_form_field_translations_resource"
  end

  def self.down
    drop_table "dynamic_form_interface_custom_file_values"
    drop_table "dynamic_form_interface_custom_option_values"
    drop_table "dynamic_form_interface_custom_options"
    drop_table "dynamic_form_interface_custom_string_values"
    drop_table "dynamic_form_interface_custom_text_values"
    drop_table "dynamic_form_interface_form_fields"
    drop_table "dynamic_form_interface_form_field_translations"
    drop_table "dynamic_form_interface_custom_file_values"
  end

end
