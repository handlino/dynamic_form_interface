# 單選,多選選項
class DynamicFormInterface::CustomOption < ActiveRecord::Base
  belongs_to :column_option, :foreign_key => 'form_field_id'

  has_many :custom_option_values, :dependent => :destroy
  
  has_many :form_field_translations, :as => :resource, :dependent => :destroy


  # title i18n
  def name
    form_field_translations.get_translation(:name) || self[:name]|| "Option #{id}"
  end 
end

