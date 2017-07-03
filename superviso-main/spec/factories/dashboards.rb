# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :dashboard do
    user nil
    name "MyString"

    factory :template do
      name "Template"
      template true
    end
  end
end
