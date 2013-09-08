# DynamicFormInterface

  使用 Active Record 的 [Nested Attributes](http://api.rubyonrails.org/classes/ActiveRecord/NestedAttributes/ClassMethods.html) 機制提供 [EAV](http://en.wikipedia.org/wiki/Entity%E2%80%93attribute%E2%80%93value_model) 功能, 並且支援多語系的欄位名稱

## Model 設定方式範例

在需要定義欄位的 Model 中添加, ex. 活動報名人表單

```ruby
class Form
  include DynamicFormInterface
  acts_as_form_hosted
end
```

在紀錄資料的 Model 中添加

```ruby
class User
  include DynamicFormInterface
  acts_as_form_interface :form
end
```

## 增加欄位範例

```ruby
  @form.build_form_fields [ {type: :text, title:'新文字欄位'}, 
                             {type: :radio, :title: "性別", 
                              :custom_options_attributes => [ { :name => "male" }, { :name => "female" } ] 
                             }
                           ]

  @form.build_form_field {type: :text, :title => '新文字欄位'}
  @from.build_form_field {type: :radio, :title: "性別", 
                            :custom_options_attributes => [ { :name => "male" }, { :name => "female" } ] 
                          }
```

## 網頁中的表單範例

有提供了 `render_input` 這個 helper 顯示表單欄位

```
<%= form_for @user, :html => {:multipart => true} do |f|%>
    <% @user.form_fields.each do | field |%>
        <%=render_input @user, field%>
    <% end %>
    <%=f.submit%>
<% end %>
```
## 資料結構說明

Form 有定義一組欄位資料, User 屬於 Form 且需要填寫 Form 定義的欄位資料

* Form has many User
* Form has many FormField


* User belongs to Form
* User has many FieldValue


* FormField belongs to Form
* FormField has many FieldValue
* FormField has many CustomOptions # 單選多選欄位


* FieldValue belongs to User
* FieldValue belongs to FormField


## License

Copyright (c) 2013 Handlino Inc.
Licensed under GPL v2.

