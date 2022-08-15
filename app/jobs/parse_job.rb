class ParseJob < ApplicationJob
  queue_as :default
  
  def get_contscts(text, reg, count = 0)
    result = []
  
    elem = text.match(reg).to_s
  
    if count = 1
      return elem
    end

    while elem != ""
      result << elem
      text.gsub!(elem, "")
      elem = text.match(reg).to_s
    end
    
    result
  end
  
  def parse_pdf(filename)
    result = [filename.split('/').last]
  
    text = ""
    reader = PDF::Reader.new(filename)
  
    reader.pages.each do |page|
      text += page.text
    end
  
    text_resume = text.delete(' ')
  
    arr = text.split("\n\n\n\n\n")
  
    if arr[0] =~ /ваканси/
      result << arr[0]
      fio_block = 1	
     else
      fio_block = 0	
      result << nil
     end 
  
    fio = arr[fio_block].split("\n")[0].strip.split(" ", 3)
  
    phone_reg = /((8|\+374|\+994|\+995|\+375|\+7|\+380|\+38|\+996|\+998|\+993)[\- ]?)?\(?\d{3,5}\)?[\- ]?\d{1}[\- ]?\d{1}[\- ]?\d{1}[\- ]?\d{1}[\- ]?\d{1}(([\- ]?\d{1})?[\- ]?\d{1})?/
    email_reg = /([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+/i
    #email_reg = /[a-z\d_+.\-]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+/i
    
    #phones = text_resume.scan(phone_reg)
    #email1 = text_resume.scan(email_reg)
  
    phone1 = get_contscts(text_resume, phone_reg, 1)
    phone2 = get_contscts(text_resume, phone_reg, 1)
    email1 = get_contscts(text_resume, email_reg, 1)
  
    result << fio[0]
    result << fio[1]
    result << fio[2]
    result << phone1.delete("() -")
    result << phone2.delete("() -")
    result << email1
  
    # arr.each do |elem|
    # 	result << elem
    # end
    
    return result	
  end
  
  def perform (*args)
    serverfiles = args[0]
    csv = CSV.open(UploadController::SERVERFILENAME, "wb", col_sep: ";", encoding: 'cp1251') 
    serverfiles.each do |filename|
      row = parse_pdf(filename)
      File.delete(filename)

      csv << row
    end

    csv.close
    
    file = File.open(UploadController::DONEFLAGFILENAME, 'wb')
    file.close
end

end
