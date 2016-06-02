class CapCountExporter
  attr_accessor :csv

  def go!
    @csv = CSV.generate do |csv|
      caps = Light.group(:cap).count.keys
      csv << ["Tech"] + caps
      Light::TECHNOLOGIES.each do |tech|
        line = [tech]
        cap_counts = Light.where(technology: tech).group(:cap).count
        caps.each { |cap| line << (cap_counts[cap] || 0) }
        csv << line
      end
    end
  end
end
