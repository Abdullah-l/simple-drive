# Simple Drive

Simple Drive is a Ruby on Rails application designed to provide a straightforward interface for storing and retrieving files. It supports multiple storage backends, including the local filesystem and FTP servers, offering flexibility in how and where files are stored.

## Features

- **Flexible Storage Options**: Choose between local storage and FTP servers for file storage.
- **RESTful API**: Easy-to-use API endpoints for uploading and downloading files.
- **Bearer Token Authentication**: Secure access to API endpoints through a fixed Bearer token authentication.

## Getting Started

### Prerequisites

- Ruby 3.2
- SQLite3

### Installation

1. Clone the repository:
  ```sh
   git clone https://github.com/Abdullah-l/simple-drive.git
   cd simple-drive
  ```
2. Install dependencies:
  ```
  bundle install
  ```
3. Create and migrate the database:
  ```
  rails db:create db:migrate
  ```
4. Start the server:
  ```
  rails server
  ```

## API Reference

### Authentication

All API requests require the use of a Bearer token for authentication. The token for accessing the API is "test".

Use the token in the Authorization header:

```
Authorization: Bearer test
```

## Endpoints

### POST /v1/blobs

Uploads a file.

#### Body:

```json
{
  "id": "unique_file_identifier",
  "data": "base64_encoded_data",
  "storage_method": "local|ftp"
}
```

### GET /v1/blobs/:id

Downloads a file.

#### Response:

```json
{
  "id": "unique_file_identifier",
  "data": "base64_encoded_data",
  "size": "file_size_in_bytes",
  "created_at": "timestamp"
}
```