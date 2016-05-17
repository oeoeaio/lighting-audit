FactoryGirl.define do
  factory :house do
    name "House"
    auditor "OD"
    house_type "Detached house"
    storey_count 4
    audit_file "some_file_name.xlsx"
    audit_date Date.today
    postcode "3333"
  end
end
