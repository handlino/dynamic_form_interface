
module DynamicFormInterface
  require 'dynamic_form_interface/engine' if defined?(Rails)

  def self.included(base)
    base.send(:extend, ClassMethods)
  end

  module ClassMethods

    # 設定 Model 的表單欄位
    #
    # @param options [Hash] 欄位參數
    # @option options [Hash] :default_fields 預設欄位內容 
    #  
    #  格式
    #
    #  ```
    #    {
    #      "設的欄位名稱" => {
    #         :type  => 欄位格式
    #         :title => 欄位名稱
    #         :is_required => 是否是必填欄位
    #         :auto_build  => 是否在 Model 建立時自動建立欄位
    #         :updateable  => 欄位是否可更新
    #         :destroyable => 欄位是否可刪除
    #         :renameable  => 欄位是否可更名
    #         :custom_options_attributes => 單選多選欄位型態提供的選項
    #       }
    #    }
    #  }
    #  ```
    #
    #  範例
    #
    #  ```
    #  { 
    #    :email  => {
    #      :type        => :email,
    #      :title       => "Email",
    #      :is_required => true,
    #      :auto_build  => true # 自動生成
    #    },
    #    :gender => {
    #      :type        => :select,
    #      :title       => "Gender",
    #      :custom_options_attributes => [ { :name => "male" }, { :name => "female" } ]
    #    }
    #  }
    #  ```
    #
    # @option options [Array] :field_types   允許使用的欄位格式
    #  支援下列幾種格式 
    #
    #  * :text 字串
    #  * :textarea 文字
    #  * :select 下拉選單
    #  * :radio 單選
    #  * :checkbox 複選
    #  * :email Email
    #  * :html Html 內容
    #  * :attachment 檔案
    #  * :date 時間
    #
    #  範例
    #
    #  ```
    #  acts_as_form_hosted :field_types => [:text, :checkbox]
    #  ```

    def acts_as_form_hosted( options = {} )
      
      cattr_accessor :default_fields, :field_types
      self.default_fields = options[:default_fields]
      
      self.field_types = options[:field_types] || [:text , :textarea, :select, :radio, :checkbox, :email, :html, :attachment, :date]
    
      has_many :form_fields,      :as => :form, :dependent => :destroy, :order => "dynamic_form_interface_form_fields.position asc, dynamic_form_interface_form_fields.id asc", :class_name => "DynamicFormInterface::FormField"
      has_many :field_text,       :as => :form, :class_name => "DynamicFormInterface::FieldText"
      has_many :field_textarea,   :as => :form, :class_name => "DynamicFormInterface::Textarea"
      has_many :field_select,     :as => :form, :include => :custom_options, :class_name => "DynamicFormInterface::FieldSelect"
      has_many :field_radio,      :as => :form, :include => :custom_options, :class_name => "DynamicFormInterface::FieldRadio"
      has_many :field_checkbox,   :as => :form, :include => :custom_options, :class_name => "DynamicFormInterface::FieldCheckbox"
      has_many :field_email,      :as => :form, :class_name => "DynamicFormInterface::FieldEmail"
      has_many :field_html,       :as => :form, :class_name => "DynamicFormInterface::FieldHtml"
      has_many :field_attachment, :as => :form, :class_name => "DynamicFormInterface::FieldAttachment"
      has_many :field_date,       :as => :form, :class_name => "DynamicFormInterface::FieldDate"
      
      accepts_nested_attributes_for :form_fields, :allow_destroy => true
      attr_accessible :form_fields
      self.field_types.each do |field_type|
        accepts_nested_attributes_for  "field_#{field_type}".to_sym, :allow_destroy => true
        attr_accessible "field_#{field_type}_attributes".to_sym
      end

      before_validation :check_default_fields
      after_save :reload_form_fields
      self.send(:include, HostedInstanceMethods)

    end

    # 設定 Model 要填寫的標單
    # @param form [Symbol] 參考的表單來源
    #  
    #  將會設定 model 與紀錄表單 model 的關聯, 例如 Event 定義了表單, Attendee 屬於 Event 且需要填寫 Event 的表單, 只需要寫成
    #  
    #   ```ruby
    #   Class Attendee
    #     acts_as_form_interface :event
    #   end
    #   ```
    def acts_as_form_interface(form)
      belongs_to form
      belongs_to :form, :class_name => form.to_s.camelcase, :foreign_key => "#{form}_id"
      delegate :form_fields, :to => form 

      has_many :custom_string_values, :as => :applicant, :dependent => :destroy, :class_name => "DynamicFormInterface::CustomStringValue"
      has_many :custom_text_values,   :as => :applicant, :dependent => :destroy, :class_name => "DynamicFormInterface::CustomTextValue"
      has_many :custom_file_values,   :as => :applicant, :dependent => :destroy, :class_name => "DynamicFormInterface::CustomFileValue"
      has_many :custom_option_values, :as => :applicant, :dependent => :destroy, :class_name => "DynamicFormInterface::CustomOptionValue"

      accepts_nested_attributes_for :custom_string_values, :custom_text_values, :custom_file_values 
      accepts_nested_attributes_for :custom_option_values, :allow_destroy => true

      before_validation :check_form_field_values

      (class << self; self; end).instance_eval {
        define_method :scope_by_form_field do |field, value|
        field = FormField.find(field) if !field.kind_of?(FormField)
        value_class = field.values_class_name.constantize
         condition_sql = if field.kind_of?(ColumnOption)
            value_class.where(["#{self.arel_table.name}.id = applicant_id and form_field_id = ? and custom_option_id = ? ", field.id, value]).to_sql
          else
            value_class.where(["#{self.arel_table.name}.id = applicant_id and form_field_id = ? and value like ? ", field.id, "%#{value}%"]).to_sql
          end
          where("exists ( #{condition_sql} )")
        end
      }

      self.send(:include, InstanceMethods)
    end
  
  end
  
  # 用來欄位所屬 Mdodel 功能
  module HostedInstanceMethods
      
    # 建立多個欄位
    # @param fields_options[Array]
    #  欄位設定資料
    # 
    # @see HostedInstanceMethods@build_form_field
    #
    def build_form_fields(fields_options)
      fields_options.map do |options|
        build_form_field(options)
      end
    end

    # 建立單一欄位
    # @param options [Hash]
    # @option options [Symbol] :type 欄位的類型
    # @see ClassMethods#acts_as_form_hosted 支援的欄位類型
    #
    # @option options [Array] :custom_options_attributes 
    #   select, radio, checkbox 型態欄位提供的選項 
    #
    #   例如性別欄位提供的會像是 `[ { :name => "male" }, { :name => "female" } ]` 
    #
    #
    # @option options [Boolean] :auto_build 是否在 Model 建立後自動建立欄位
    # @option options [Boolean] :is_required 是否為必填欄位
    # @option options [String]  :title 欄位名稱
    # @option options [Boolean] :updateable 欄位是否可更新
    # @option options [Boolean] :destroyable 欄位是否可刪除
    # @option options [Boolean] :renameable 欄位是否可更名

    def build_form_field(options)
      field_type = (options[:type] || 'text').to_sym # ex. FieldText => :text, FieldSelect => :select

      # 檢查輸入的欄位格式, 是否被允許
      if  self.class.field_types.include?( field_type ) 
        # 建立欄位
        field_class =  "dynamic_form_interface::Field_#{field_type}".camelcase.constantize
        if field_class.ancestors.include?( DynamicFormInterface::FormField ) 
          options.delete(:custom_options_attributes)  if field_class.superclass != DynamicFormInterface::ColumnOption
          options.delete(:type)
          return self.send(field_class.to_s.split(/::/).last.underscore.to_sym).build( options ) 
        end
      end

      raise "wrong field type, only allow #{self.class.field_types.inspect}"
    end

    # 更新欄位設定資料
    # @param field_id [Integer] 欄位 ID
    # @param data [Hash] 欄位設定資料
    def update_form_field(field_id, data)
      form_field = self.form_fields.find( field_id )
      data = data[ form_field.class.to_s.underscore.to_sym ] || data
      data.delete(:custom_options_attributes)  if form_field.class.superclass != DynamicFormInterface::ColumnOption
      if data[:custom_options_attributes]
        data[:custom_options_attributes].delete_if{|x| x[:name].blank? }
      end 
      form_field.update_attributes( data )
    end

    # 透過預設欄位名稱建立預設欄位
    def build_default_field(field_name)
      # clone 資料出來處理避免修改了 class var.
      attributes = self.class.default_fields[field_name].clone
      attributes.delete :auto_build # 移除自動建立的參數

      # 如果已經有相同名稱的預設欄位存在則不處理
      field_name = field_name.to_s
      unless self.form_fields.any?{|x| x.default_field == field_name}
        field_type = attributes.delete(:type)
        attributes[:is_required] = attributes[:is_required].blank? ? 0 : 1
        attributes[:updateable]  = attributes[:updateable].blank?  ? 0 : 1
        attributes[:renameable]  = attributes[:renameable].blank?  ? 0 : 1
        attributes[:destroyable] = attributes[:destroyable].blank?  ? 0 : 1
        self.send("field_#{field_type}").build( attributes.merge(:default_field => field_name) )
      end
    end

    def check_default_fields
      if self.class.default_fields
        self.class.default_fields.each do |default_field_name, attributes|
          next unless attributes[:auto_build] # 除非設定了自動建立
          build_default_field( default_field_name )
        end
      end
    end

    def reload_form_fields
      self.form_fields(true)
    end
  end

  module InstanceMethods
    # 取得欄位跟對應的值
    # @return [Hash]
    # `{ 欄位 => 值 }`
    def field_and_values()
      hash={}
      self.form_fields.each do | field |
        next  if field.is_a?(DynamicFormInterface::FieldHtml)
        hash[ field ] = field.get_value_by_applicant(self)
      end
      return hash
    end
    
    # 取得特定欄位的值
    # @param [FormField] field 欄位
    def get_value_by_field(field) 
      field.get_value_by_applicant(self)
    end

    # 檢查欄位值是否符合條件
    def check_form_field_values
      # 取出所有必填的欄位 id
      required_form_field_ids = self.form_fields.map{|x| x.id if x.is_required }
      required_form_field_ids.compact!

      self.custom_file_values.delete_if{   |x| x.asset.blank? }
      self.custom_option_values.delete_if{ |x| x.custom_option_id.blank? }
    
      # 將取出的所有必填欄位 id 刪除有填寫值的欄位
      self.custom_string_values.each{ |x| required_form_field_ids.delete( x.form_field_id ) }
      self.custom_text_values.each{   |x| required_form_field_ids.delete( x.form_field_id ) }
      self.custom_file_values.each{   |x| required_form_field_ids.delete( x.form_field_id ) }
      self.custom_option_values.each{ |x| required_form_field_ids.delete( x.form_field_id ) }

      # 如果還有必填欄位 id 存在, 代表該欄位沒有填寫資料, 需添加錯誤訊息
      if !required_form_field_ids.blank?
        required_form_field_ids.each do |x|
          self.errors.add( "form_field_#{x}", I18n.t("errors.messages.empty") )  
        end
      end
    end

    # 取得欄位的錯誤訊息, 並且將其轉換為人類看得懂的格式
    def get_form_field_errors
      errors = {}
      self.errors.messages.each { |field_key, messages|
        field_key.to_s =~ /^custom_.*_values\.form_field_(\d+)/
        errors[$1]={title: self.form_fields.find($1).title,
          messages: messages}

      }
      errors
    end
  end    

end
