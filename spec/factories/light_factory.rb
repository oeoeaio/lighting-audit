FactoryGirl.define do
  factory :light do
    house
    room
    switch
    name "L1"
    connection_type "P"
    fitting "Batton Holder"
    colour "C"
    technology "LED directional"
    shape "Reflector - R"
    cap "GU10"
    transformer "N/A (240V)"
    wattage "5"
    wattage_source "Label"
    usage "5"
    tech_mod "LED directional"
    mains_reflector 0.7
    row 8
    power_multiplier 1.163
    power_add 0
    log_multiplier 10.361
    log_add 29.131
    power_adj 7
    efficacy 59.1
    lumens 853.3
    lumens_round 853
  end
end
