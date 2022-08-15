class UploadController < ApplicationController
  SERVERFILENAME = Rails.root.join('public', 'data', 'result.csv')
  DONEFLAGFILENAME = Rails.root.join('public', 'data', 'resultflag')
  MESSAGES = ['Обработка всё еще выполняется, подождите еще не много...', 
    'Минуту терпения, пожалуйста..', 
    'Вызагрузили слишком много файлов, они еще борабатываются..', 
    'Придется еще потерпеть...', 
    'Нужно потерпеть масимум несколько минут...', 
    'Массив из 100-200 файлов обрабатывается 2-3-4 минуты...', 
    'Попробуйте повторить попытку чуть позднее...']
 
  def index
  end

  def create
    
    if File.exist?(DONEFLAGFILENAME)
      File.delete(DONEFLAGFILENAME)
    end  

    uploaded_files = params[:upload]
    #csv = CSV.open(SERVERFILENAME, "wb", col_sep: ";", encoding: 'cp1251')
    serverfiles = [] 
    uploaded_files.each do |uploaded_file|
        # row = parse_pdf(uploaded_file.tempfile.path, uploaded_file.original_filename)
        # csv << row
        file = File.open(Rails.root.join('public', 'data', uploaded_file.original_filename), 'wb')
        file.write(uploaded_file.read)
        file.close
        serverfiles << file.path
        # row = parse_pdf(file.path)
        # File.delete(file.path)

        # csv << row
    end

    #csv.close
    ParseJob.perform_later serverfiles
    redirect_to root_path, notice: 'Выполняется обработка, ожидайте...'

    #redirect_to root_path, notice: 'Скачать'
  end

  def download_result
    if File.exist?(DONEFLAGFILENAME)
      time = Time.now
      filename = "Результат " + time.strftime("%Y.%m.%d %H-%M-%S") + ".csv"
      send_file(SERVERFILENAME, disposition: 'inline', filename: filename)
    else
      redirect_to root_path, notice: MESSAGES.sample
    end  
  end

end
