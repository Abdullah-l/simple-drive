require 'rails_helper'

RSpec.describe StorageService do
  let(:storage_path) { Rails.root.join('storage') }
  let(:service) { described_class.new }
  let(:file_path) { File.join(storage_path, file_name) }
  let(:file_name) { 'test_blob' }
  let(:file_content) { 'Hello, world!' }
  let(:ftp_details) do
    { host: 'ftp.example.com', username: 'user', password: 'password', directory: '/path/to/dir' }
  end

  before do
    allow(Rails.application.credentials).to receive(:ftp).and_return(ftp_details)
    Dir.mkdir(storage_path) unless Dir.exist?(storage_path)
  end

  after do
    FileUtils.rm_rf(storage_path) if Dir.exist?(storage_path)
  end

  describe 'Local storage' do
    describe '#upload' do
      it 'writes data to a file' do
        service.upload(file_name, file_content)
        expect(File.read(file_path)).to eq(file_content)
      end
    end

    describe '#download' do
      context 'when the file exists' do
        before do
          File.write(file_path, file_content)
        end

        it 'reads the content of the file' do
          expect(service.download(file_name)).to eq(file_content)
        end
      end

      context 'when the file does not exist' do
        it 'returns nil' do
          expect(service.download('nonexistent')).to be_nil
        end
      end
    end
  end

  describe 'FTP storage' do
    let(:service) { described_class.new(storage_method: :ftp) }
    let(:ftp) { instance_double(Net::FTP) }

    before do
      allow(Net::FTP).to receive(:open).and_yield(ftp)
      allow(ftp).to receive(:login).with(ftp_details[:username], ftp_details[:password])
      allow(ftp).to receive(:chdir).with(ftp_details[:directory])
    end

    describe '#upload' do
      it 'uploads data to FTP server' do
        expect(ftp).to receive(:putbinaryfile).with(instance_of(StringIO), file_name)
        service.upload(file_name, file_content)
      end
    end

    describe '#download' do
      it 'downloads data from FTP server' do
        expect(ftp).to receive(:getbinaryfile).with(file_name, nil).and_yield(file_content)
        expect(service.download(file_name)).to eq(file_content)
      end

      context 'when the file does not exist on the FTP server' do
        it 'returns nil and logs an error' do
          allow(ftp).to receive(:getbinaryfile).with('nonexistent', nil).and_raise(Net::FTPPermError)
          expect(Rails.logger).to receive(:error).with(/Failed to download file:/)
          expect(service.download('nonexistent')).to be_nil
        end
      end
    end
  end
end
