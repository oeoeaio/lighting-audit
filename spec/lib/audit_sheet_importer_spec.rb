require 'spec_helper'
require 'audit_sheet_importer'

describe AuditSheetImporter do
  let(:file) { ActionDispatch::Http::UploadedFile.new({
    :filename => '10-2016LightingSurvey-IDG15V3.xlsx',
    :content_type => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    :tempfile => File.new("spec/data/10-2016LightingSurvey-IDG15V3.xlsx")
  }) }

  let(:importer) { AuditSheetImporter.new(files: [file]) }
  let(:house) { House.first }

  before do
    importer.go!
  end

  it "imports a file a file" do
    expect(house.name).to eq "G15"
    expect(house.auditor).to eq "HH"
    expect(Room.count).to eq 14
    expect(Switch.count).to eq 25
    expect(Light.count).to eq 44
  end
end
