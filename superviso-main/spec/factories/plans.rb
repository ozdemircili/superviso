# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :plan do
    name "MyString"
    description "MyText"
    dashboard_quota 1
    widget_quota 1
    update_rate 1
  end
end
