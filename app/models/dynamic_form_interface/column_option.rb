class DynamicFormInterface::ColumnOption < DynamicFormInterface::FormField
  validates_presence_of :title

  has_many :custom_options, :foreign_key => 'form_field_id', :dependent => :destroy
  has_many :values, :class_name => "CustomOptionValue", :foreign_key => 'form_field_id', :dependent => :destroy

  validates_associated :custom_options 

  accepts_nested_attributes_for :custom_options, :allow_destroy => true

end
