# These are fixes for issues with the original efficacy calculations in the sheet

class EfficacyUpdater
  def go!(lights)
    lights = Light.where(id: lights.pluck(:id))

    cflsb_ids = lights.where(row: [8,10,11], power_add: 8).pluck(:id)
    cfl_separate_ballast_lights = lights.where(id: cflsb_ids)
    cfl_separate_ballast_lights.update_all('power_add = 6')
    cfl_separate_ballast_lights.where.not(wattage_source: 'Measurement').update_all('power_adj = power_adj - 2')

    lvh_ids = lights.where(row: [3,4,5,6], log_multiplier: 0, log_add: 14).pluck(:id)
    low_voltage_halogen_lights = lights.where(id: lvh_ids)
    low_voltage_halogen_lights.update_all('log_multiplier = 3.2054, log_add = 1.8855')
    low_voltage_halogen_lights.update_all('efficacy = (log_multiplier*ln(wattage)+log_add)*mains_reflector')
    low_voltage_halogen_lights.update_all('lumens = efficacy*wattage, lumens_round = round(efficacy*wattage/50)*50')

    separate_tranformer_technologies = ['LED directional (12V)', 'Halogen - low voltage', 'CFL - separate ballast']
    measured_with_separate_transformer = lights.where(wattage_source: 'Measurement', tech_mod: separate_tranformer_technologies)
    measured_with_separate_transformer.update_all('efficacy = (log_multiplier*ln((power_adj-power_add)/power_multiplier)+log_add)*mains_reflector')
    measured_with_separate_transformer.update_all('lumens = efficacy*((power_adj-power_add)/power_multiplier), lumens_round = round(efficacy*((power_adj-power_add)/power_multiplier)/50)*50')

    lights.update_all('overall_efficacy = lumens/power_adj')
  end
end
