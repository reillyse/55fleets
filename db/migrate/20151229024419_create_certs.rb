class CreateCerts < ActiveRecord::Migration
  def change
    create_table :certs do |t|
      t.text :encrypted_certificate
      t.text :encrypted_certificate_salt
      t.text :encrypted_certificate_iv

      t.text :encrypted_private_key
      t.text :encrypted_private_key_salt
      t.text :encrypted_private_key_iv

      t.text :cert_chain
      t.text :aws_ssl_cert_id
      t.text :port
      t.text :name

      t.timestamps null: false
    end
  end
end
