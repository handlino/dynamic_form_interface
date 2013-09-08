# 紀錄 Text 欄位值
class DynamicFormInterface::CustomStringValue < ActiveRecord::Base
  belongs_to :form_field
  belongs_to :form,      :polymorphic => true
  belongs_to :applicant, :polymorphic => true

  validates_presence_of :form_field_id
  validate :check_value

  validates_uniqueness_of :applicant_id, :scope => [:form_field_id, :applicant_type]

  before_save :set_relaction

  # 檢查欄位值是否符合條件
  # 如果欄位是必填的話會檢查欄位是否有值
  # 如果欄位格式是 Email 的話會檢查是否符合 Email 格式
  def check_value
    if form_field.is_required && self.value.blank?
      errors.add("form_field_#{form_field.id}", I18n.t("errors.messages.empty") )
      return false
    end

    if form_field.is_a?(DynamicFormInterface::FieldEmail)
      if !( self.value.blank? || self.value =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i)
        errors.add("form_field_#{form_field.id}", I18n.t("errors.messages.invalid") )
        return false
      end
    end
  end
  
  # 設定關聯
  def set_relaction

    self.form_type = self.applicant.form.class.to_s
    self.form_id = self.applicant.form.id
    if self.form_id != self.form_field.form_id
      errors.add("form_field_#{form_field.id}", I18n.t("errors.messages.invalid") )
      return false
    end
  end
 
end

