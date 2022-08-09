class UploadController < ApplicationController
  
  def index
  end

  def create
    uploaded_files = params[:upload]
    csv = CSV.open(Rails.root.join('public', 'data', "result.csv"), "wb", col_sep: ";", encoding: 'cp1251') 

    uploaded_files.each do |uploaded_file|
      File.open(Rails.root.join('public', 'data', uploaded_file.original_filename), 'wb') do |file|
        file.write(uploaded_file.read)
        row = parse_pdf(file.path)
        File.delete(file.path)

        csv << row
      end
    end

    csv.close

    redirect_to root_path, notice: csv.path
  end

  def download_result
    time = Time.now
    filename = "Результат " + time.strftime("%Y.%m.%d %H-%M-%S") + ".csv"
    serverfilename = Rails.root.join('public', 'data', "result.csv")
    send_file(serverfilename, disposition: 'inline', filename: filename)
    #redirect_to root_path
  end

end
