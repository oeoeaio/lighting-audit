require 'spec_helper'
require 'audit_sheet_importer'

describe AuditSheetImporter do
  it "loads a file" do
    file = ActionDispatch::Http::UploadedFile.new({
      :filename => '10-2016LightingSurvey-IDG15V3.xlsx',
      :content_type => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      :tempfile => File.new("spec/data/10-2016LightingSurvey-IDG15V3.xlsx")
    })
    importer = AuditSheetImporter.new(files: [file])
  end
end
