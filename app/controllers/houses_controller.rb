require 'audit_sheet_importer'
class HousesController < ApplicationController
  def new_multiple
    authorize House
  end

  def create_multiple
    authorize House
    files = params[:houses][:audit_files]
    files.keep_if{ |f| f.content_type == "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" }
    importer = AuditSheetImporter.new files: files
    importer.go!
    @file_issues = importer.file_issues
    @issues = importer.issues
    if @issues.any?
      flash[:error] = "File upload cancelled, please fix the following errors"
      render :new_multiple
    else
      flash[:success] = "All files uploaded successfully"
      redirect_to new_multiple_houses_path
    end
  end
end
