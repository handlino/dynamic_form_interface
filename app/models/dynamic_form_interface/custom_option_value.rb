class DynamicFormInterface::CustomOptionValue < ActiveRecord::Base
  belongs_to :form_field
  belongs_to :custom_option
  
  belongs_to :form,      :polymorphic => true
  belongs_to :applicant, :polymorphic => true

  validates_presence_of :custom_option_id
  validates_numericality_of :custom_option_id

  before_create :set_relaction
  before_create :only_one_value
  
  validates_uniqueness_of :applicant_id, :scope => [:form_field_id, :applicant_type], :unless => Proc.new { |x| x.form_field.is_a?(DynamicFormInterface::FieldCheckbox) }

  def value
    self.custom_option.name
  end 

  private
  def set_relaction
    self.form_field_id = self.custom_option.form_field_id unless self.form_field_id
    self.form_type = self.applicant.form.class.to_s
    self.form_id = self.applicant.form.id
    if self.form_id != self.form_field.form_id
      errors.add("form_field_#{form_field.id}", I18n.t("errors.messages.invalid") )
      return false
    end
  end

  def only_one_value
    unless self.form_field.is_a? DynamicFormInterface::FieldCheckbox
      if self.class.where( :form_field_id => form_field, 
                          :applicant_id => self.applicant.id,
                          :applicant_type => self.applicant.class.to_s ).exists?
        errors.add("form_field_#{form_field.id}", I18n.t("errors.messages.too_much_value") )
        return false
      end
    end
  end

end

