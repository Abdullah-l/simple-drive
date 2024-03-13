module V1
  class BlobsController < ApplicationController
    before_action :authenticate!

    def create
      blob_identifier = params[:id]
      storage_method = params[:storage_method] || :local
      data = Base64.decode64(params[:data])

      StorageService.new(storage_method:).upload(blob_identifier, data)

      render json: { identifier: blob_identifier }, status: :created
    rescue StandardError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end

    def show
      blob_identifier = params[:id]
      storage_method = params[:storage_method] || :local

      data = StorageService.new(storage_method:).download(blob_identifier)
      if data
        render json: {
          identifier: blob_identifier,
          data: Base64.encode64(data),
          size: data.size,
          created_at: Time.current
        }
      else
        render json: { error: 'Blob not found' }, status: :not_found
      end
    rescue StandardError => e
      render json: { error: e.message }, status: :not_found
    end

    private

    def authenticate!
      provided_token = request.headers['Authorization']&.split(' ')&.last
      valid_token = Rails.application.credentials.api_access_token

      render json: { error: 'Unauthorized' }, status: :unauthorized unless provided_token == valid_token
    end
  end
end
