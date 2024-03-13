require 'net/ftp'

class StorageService
  def initialize(storage_method: :local)
    @storage_method = storage_method
    setup_storage
  end

  def upload(file_path, data)
    case @storage_method
    when :local
      upload_local(file_path, data)
    when :ftp
      upload_ftp(file_path, data)
    else
      raise NotImplementedError, "Storage method #{@storage_method} is not implemented"
    end
  end

  def download(file_path)
    case @storage_method
    when :local
      download_local(file_path)
    when :ftp
      download_ftp(file_path)
    else
      raise NotImplementedError, "Storage method #{@storage_method} is not implemented"
    end
  end

  private

  def setup_storage
    case @storage_method
    when :local
      @storage_dir = "#{Rails.root}/storage"
      Dir.mkdir(@storage_dir) unless Dir.exist?(@storage_dir)
    when :ftp
      @ftp_details = Rails.application.credentials.ftp
    else
      raise NotImplementedError, "Storage method #{@storage_method} is not implemented"
    end
  end

  def upload_local(file_path, data)
    full_path = File.join(@storage_dir, file_path)
    File.open(full_path, 'wb') { |file| file.write(data) }
  end

  def download_local(file_path)
    full_path = File.join(@storage_dir, file_path)
    File.binread(full_path)
  rescue StandardError => e
    Rails.logger.error "Failed to read file: #{e.message}"
    nil
  end

  def upload_ftp(file_path, data)
    Net::FTP.open(@ftp_details[:host], @ftp_details[:username], @ftp_details[:password]) do |ftp|
      ftp.chdir(@ftp_details[:directory])
      ftp.putbinaryfile(StringIO.new(data), file_path)
    end
  end

  def download_ftp(file_path)
    data = ''
    Net::FTP.open(@ftp_details[:host], @ftp_details[:username], @ftp_details[:password]) do |ftp|
      ftp.chdir(@ftp_details[:directory])
      ftp.getbinaryfile(file_path, nil) { |chunk| data << chunk }
    end
    data
  rescue StandardError => e
    Rails.logger.error "Failed to download file: #{e.message}"
    nil
  end
end
