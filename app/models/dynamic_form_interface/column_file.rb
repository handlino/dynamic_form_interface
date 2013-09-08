class DynamicFormInterface::ColumnFile < DynamicFormInterface::FormField

  validates_presence_of :title

  has_many :values, :class_name => "CustomFileValue", :foreign_key => 'form_field_id', :dependent => :destroy

end
