class CreateBlobs < ActiveRecord::Migration[7.1]
  def change
    create_table :blobs do |t|
      t.string :identifier
      t.integer :size

      t.timestamps
    end
  end
end
