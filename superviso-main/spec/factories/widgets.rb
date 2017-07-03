# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :widget do
    dashboard nil
    name "MyString"
    color "#00ff00"
    factory :widget_text, class: Widgets::Text do
      title "title"
    end
  end

  
end
