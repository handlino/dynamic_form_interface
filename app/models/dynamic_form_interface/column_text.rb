class DynamicFormInterface::ColumnText < DynamicFormInterface::FormField
  
  validates_presence_of :title
  
  has_many :values, :class_name => "CustomTextValue", :foreign_key => 'form_field_id', :dependent => :destroy
  validates_numericality_of :rows, :on => :save, :greater_than => 1
  validates_numericality_of :cols, :on => :save, :greater_than => 1
  
end
