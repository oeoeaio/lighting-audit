class FittingSummaryExporter
  attr_accessor :csv

  def go!
    @csv = CSV.generate do |csv|
      fittings = Light.group(:fitting).count.keys.sort
      csv << [""] + fittings.count.times.map{ "Count" } + fittings.count.times.map{ "Watts" } + fittings.count.times.map{ "Lumens" }
      csv << ["Tech"] + fittings + fittings + fittings
      Light::TECHNOLOGIES.each do |tech|
        line = [tech]
        fitting_counts = Light.where(tech_mod: tech).group(:fitting).count
        fittings.each { |fitting| line << (fitting_counts[fitting] || 0) }
        fitting_watts = Light.where(tech_mod: tech).group(:fitting).sum(:power_adj)
        fittings.each { |fitting| line << (fitting_watts[fitting] || "NULL") }
        fitting_lumens = Light.where(tech_mod: tech).group(:fitting).sum(:lumens)
        fittings.each { |fitting| line << (fitting_lumens[fitting] || "NULL") }
        csv << line
      end
    end
  end
end
