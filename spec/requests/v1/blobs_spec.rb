# spec/requests/v1/blobs_spec.rb

require 'rails_helper'

RSpec.describe 'V1::Blobs', type: :request do
  let(:storage_service) { StorageService.new }
  let(:file_name) { 'test_blob' }
  let(:file_data) { 'Hello, world!' }
  let(:encoded_data) { Base64.encode64(file_data) }
  let(:valid_token) { Rails.application.credentials.api_access_token }
  let(:invalid_token) { 'invalid_token' }

  before do
    allow(StorageService).to receive(:new).and_return(storage_service)
  end

  describe 'POST /v1/blobs' do
    let(:valid_headers) { { 'Authorization' => "Bearer #{valid_token}" } }
    let(:invalid_headers) { { 'Authorization' => "Bearer #{invalid_token}" } }
    let(:valid_params) { { id: file_name, data: encoded_data } }

    context 'with valid authentication' do
      before do
        allow(storage_service).to receive(:upload).with(file_name, file_data).and_return(nil)
      end

      it 'stores the blob' do
        post v1_blobs_path, params: valid_params, headers: valid_headers
        expect(response).to have_http_status(:created)
        expect(storage_service).to have_received(:upload).with(file_name, file_data)
      end
    end

    context 'with invalid authentication' do
      it 'returns unauthorized' do
        post v1_blobs_path, params: valid_params, headers: invalid_headers
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /v1/blobs/:id' do
    let(:valid_headers) { { 'Authorization' => "Bearer #{valid_token}" } }
    let(:invalid_headers) { { 'Authorization' => "Bearer #{invalid_token}" } }

    context 'with valid authentication' do
      context 'when the file exists' do
        before do
          allow(storage_service).to receive(:download).with(file_name).and_return(file_data)
        end

        it 'retrieves the blob' do
          get v1_blob_path(file_name), headers: valid_headers
          expect(response).to have_http_status(:ok)
          expect(response.body).to include(encoded_data.strip)
        end
      end

      context 'when the file does not exist' do
        before do
          allow(storage_service).to receive(:download).with(file_name).and_return(nil)
        end

        it 'returns a not found status' do
          get v1_blob_path(file_name), headers: valid_headers
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'with invalid authentication' do
      it 'returns unauthorized' do
        get v1_blob_path(file_name), headers: invalid_headers
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
