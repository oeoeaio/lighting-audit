class CapSummaryByFittingExporter
  attr_accessor :csv

  def go!
    @csv = CSV.generate do |csv|
      fittings = Light.group(:fitting).count.keys.sort
      caps = Light.group(:cap).count.keys.sort
      csv << [""] + caps.count.times.map{ "Count" } + caps.count.times.map{ "Watts" } + caps.count.times.map{ "Lumens" }
      csv << ["Tech"] + caps + caps + caps
      fittings.each do |fitting|
        line = [fitting]
        cap_counts = Light.where(fitting: fitting).group(:cap).count
        caps.each { |cap| line << (cap_counts[cap] || 0) }
        cap_watts = Light.where(fitting: fitting).group(:cap).sum(:power_adj)
        caps.each { |cap| line << (cap_watts[cap] || "NULL") }
        cap_lumens = Light.where(fitting: fitting).group(:cap).sum(:lumens)
        caps.each { |cap| line << (cap_lumens[cap] || "NULL") }
        csv << line
      end
    end
  end
end
