class DynamicFormInterface::CustomFileValue < ActiveRecord::Base

  belongs_to :form_field
  belongs_to :form,      :polymorphic => true
  belongs_to :applicant, :polymorphic => true

  validates_presence_of :form_field_id

  validates_uniqueness_of :applicant_id, :scope => [:form_field_id, :applicant_type]

  mount_uploader :asset, FormFieldUploader

  before_save :set_relaction

  before_save :set_asset_size

  private
  def set_relaction
    self.form_type = self.applicant.form.class.to_s
    self.form_id = self.applicant.form.id
    if self.form_id != self.form_field.form_id
      errors.add("form_field_#{form_field.id}", I18n.t("errors.messages.invalid") )
      return false
    end
  end

  def set_asset_size
    self.asset_size = asset.size if asset
  end
end
