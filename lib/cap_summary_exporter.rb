class CapSummaryExporter
  attr_accessor :csv

  def go!
    @csv = CSV.generate do |csv|
      caps = Light.group(:cap).count.keys
      csv << [""] + caps.count.times.map{ "Count" } + caps.count.times.map{ "Watts" } + caps.count.times.map{ "Lumens" }
      csv << ["Tech"] + caps + caps + caps
      Light::TECHNOLOGIES.each do |tech|
        line = [tech]
        cap_counts = Light.where(tech_mod: tech).group(:cap).count
        caps.each { |cap| line << (cap_counts[cap] || 0) }
        cap_watts = Light.where(tech_mod: tech).group(:cap).sum(:power_adj)
        caps.each { |cap| line << (cap_watts[cap] || "NULL") }
        cap_lumens = Light.where(tech_mod: tech).group(:cap).sum(:lumens)
        caps.each { |cap| line << (cap_lumens[cap] || "NULL") }
        csv << line
      end
    end
  end
end
