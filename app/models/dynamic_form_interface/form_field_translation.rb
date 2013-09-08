# 紀錄欄位名稱 I18n
class DynamicFormInterface::FormFieldTranslation < ActiveRecord::Base

  belongs_to :resource, :polymorphic => true

  # 取得當下語系的 I18n 結果
  #
  # @param attr [Symbol] 欄位名稱
  # @param attr_type [Symbol] 欄位類型
  #   
  #   支援 :string 跟 :text 兩種格式, 若預期需儲存大於 255 字元的字串時, 應選用 :text 格式
  #
  # @param obj [Object] 欄位所屬的 Model
  #
  # @return [String] 如找不到符合條件的設定會回傳 nil
  def self.get_translation(attr, attr_type = :string, obj = nil )
    if !obj
      where(:attribute_name => attr, :locale => I18n.locale).first.try("#{attr_type}_value") 
    else
      where(:resource => obj, :attribute_name => attr, :locale => I18n.locale).first.try("#{attr_type}_value")
    end
  end
end

