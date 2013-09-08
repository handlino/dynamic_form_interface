# 多選欄位
class DynamicFormInterface::FieldCheckbox < DynamicFormInterface::ColumnOption

  # 取得特定填表人所填得值
  # @return [Array] 回傳 DynamicFormInterface::CustomOptionValue
  def get_value_by_applicant(applicant)
    self.values.where(:applicant_id => applicant.id, :applicant_type => applicant.class.to_s ).all
  end 
end
