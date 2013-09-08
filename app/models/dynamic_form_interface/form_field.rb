# 提供 STI 架構的欄位 Model
# 特定類型的欄位都將繼承這個 Class
class DynamicFormInterface::FormField < ActiveRecord::Base
  has_many :form_field_translations, :as => :resource, :include => true, :dependent => :destroy

  belongs_to :form, :polymorphic => true

  validate :check_updateable?, :on => :update
  validate :check_renameable?, :on => :update
  
  before_destroy :check_destroyable?

  # title i18n
  # @return [String] 會依序回傳符合條件的 I18n 結果, Model 的 title 屬性, "Field $id title"
  def title 
    form_field_translations.get_translation(:title) || self['title'] || "Field #{id} Title"
  end 

  # description i18n
  # @return [String] 會依序回傳符合條件的 I18n 結果, Model 的 description 屬性, "Field $id description"
  def description
    form_field_translations.get_translation(:description, :text) || self[:description] ||"Field #{id} description"
  end 

  # 取得紀錄欄位值所用的 Class 名稱
  def values_name
    self.class.reflections[:values].options[:class_name].underscore.pluralize
  end
  
  # 取得紀錄欄位值所用的 Class 名稱
  def values_class_name
    self.class.reflections[:values].options[:class_name]
  end

  # 取得特定填表人的值
  # @param applicant [Model] 填表人的欄位
  #
  def get_value_by_applicant(applicant)
    self.values.where(:applicant_id => applicant.id, :applicant_type => applicant.class.to_s ).first
  end 

  # 取得欄位類型 
  def field_type
    (type.match /Field(\w+)/)[1].underscore
  end

  private

  # 檢查是否可以更新
  def check_updateable?
    if !self.updateable
      self.errors.add(:base, I18n.t('errors.messages.exclusion') )
    end
  end
  
  # 檢查是否可以更名
  def check_renameable?
    if !self.renameable
      if self.title_changed? 
        self.errors.add(:base, I18n.t('errors.messages.exclusion') )
      end
    end
  end


  # 檢查是否可以刪除
  def check_destroyable?
    if !self.destroyable
      raise I18n.t('errors.messages.exclusion') 
    end
  end
end

