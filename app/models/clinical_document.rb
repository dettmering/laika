class ClinicalDocument < ActiveRecord::Base

  has_attachment :content_type => 'text/xml', 
                 :storage => :file_system, 
                 :max_size => 500.kilobytes

  belongs_to :vendor_test_plan

  # prevent records from being created when there is no associated file data
  validates_presence_of :filename, :size

  def destroy
    File.unlink(validation_report_filename)
    super
  end


  # return the contents of the document as an REXML::Document
  # if the current data is nil attachemnt_foo  will throw a conversion error
  def as_xml_document(remove_stylesheets = false)  
    # pulling this in instead of calling fro it from the file store everytime we need it
    data = current_data
    data = data.gsub(/\<\?xml\-stylesheet.*\?\>/,'') if  remove_stylesheets
    data  ? REXML::Document.new(data) : nil
  end
 
 
  # get the contents of the validation report or nil if one does not exist
  def validation_report(format=:string)
    if File.exists?(validation_report_filename)
      report = ""
      File.open(validation_report_filename) do |f|
        report = f.read()
      end
      return format == :string ? report : REXML::Document.new(report)
    end
  end

  # Save the rport to a file
  def validation_report=(rep)
    case rep
    when String
      File.open(validation_report_filename,'w') do |f|
        f.puts rep
      end
    when REXML::Document
      File.open(validation_report_filename,'w') do |f|
        f.puts rep.to_s
      end             
    when File
      File.copy(rep.path,validation_report_filename)
    end         
  end

  # get the path of the validation report file this is based off of the 
  # full path of the clinical document file . If this is changed to use the db
  # as a persistance method then this will fail to work correctly
  def validation_report_filename
    return self.full_filename.gsub(self.filename,"clinical_document_report_#{self.id}.xml")
  end

  # has this document been validated? 
  # This is determinded by whether or not the validation report file exists or not
  def validated?
    File.exists?(validation_report_filename) 
  end

end
