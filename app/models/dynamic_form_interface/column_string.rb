class DynamicFormInterface::ColumnString < DynamicFormInterface::FormField
  
  validates_presence_of :title
  
  has_many :values , :class_name => "CustomStringValue", :foreign_key => 'form_field_id', :dependent => :destroy
  validates_numericality_of :size, :on => :save, :greater_than => 1

end

