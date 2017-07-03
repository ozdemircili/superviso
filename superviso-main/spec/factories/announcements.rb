# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :announcement do
    title "MyString"
    message "MyText"
    starts_at "2014-01-19 11:35:26"
    ends_at "2014-01-19 11:35:26"
  end
end
