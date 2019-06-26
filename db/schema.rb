# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20190614223643) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.text     "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "apps", force: :cascade do |t|
    t.integer  "user_id"
    t.text     "name"
    t.integer  "account_id"
    t.integer  "repo_id"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.string   "slug"
    t.string   "health_check_target", default: "HTTP:80/"
    t.boolean  "active"
    t.string   "state"
    t.integer  "should_flip",         default: 300
  end

  add_index "apps", ["slug"], name: "index_apps_on_slug", using: :btree

  create_table "certificate_load_balancers", force: :cascade do |t|
    t.integer  "load_balancer_id"
    t.integer  "cert_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "certs", force: :cascade do |t|
    t.text     "encrypted_certificate"
    t.text     "encrypted_certificate_salt"
    t.text     "encrypted_certificate_iv"
    t.text     "encrypted_private_key"
    t.text     "encrypted_private_key_salt"
    t.text     "encrypted_private_key_iv"
    t.text     "cert_chain"
    t.text     "aws_ssl_cert_id"
    t.text     "port"
    t.text     "name"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "app_id"
    t.integer  "user_id"
  end

  create_table "env_configs", force: :cascade do |t|
    t.text     "encrypted_value"
    t.text     "encrypted_value_salt"
    t.text     "encrypted_value_iv"
    t.integer  "app_id"
    t.integer  "pod_id"
    t.string   "name"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "fleet_configs", force: :cascade do |t|
    t.text     "state"
    t.integer  "app_id"
    t.integer  "repo_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "fleets", force: :cascade do |t|
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "app_id"
    t.datetime "rolling_deploy_started_at"
    t.datetime "rolling_deploy_completed_at"
    t.datetime "rolling_deploy_failed_at"
    t.integer  "fleet_config_id"
    t.datetime "deregistered"
  end

  add_index "fleets", ["app_id"], name: "index_fleets_on_app_id", using: :btree

  create_table "internet_gateways", force: :cascade do |t|
    t.integer  "vpc_id"
    t.text     "internet_gateway_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  create_table "load_balancers", force: :cascade do |t|
    t.text     "name"
    t.text     "state"
    t.text     "subnet_id"
    t.integer  "app_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "url"
    t.text     "arn"
  end

  create_table "load_balancers_machines", force: :cascade do |t|
    t.integer "load_balancer_id"
    t.integer "machine_id"
  end

  create_table "machine_images", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "ami"
    t.datetime "built_at"
  end

  create_table "machines", force: :cascade do |t|
    t.integer  "app_id"
    t.text     "instance_id"
    t.text     "instance_type"
    t.text     "ip_address"
    t.text     "state"
    t.datetime "started_at"
    t.datetime "stopped_at"
    t.text     "ami_name"
    t.integer  "vpc_id"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.integer  "pod_id"
    t.datetime "deployed_at"
    t.string   "type"
    t.integer  "spot_fleet_request_id"
    t.datetime "logging_until"
    t.integer  "subnet_id"
    t.datetime "busy"
    t.text     "build_notes"
  end

  add_index "machines", ["instance_id"], name: "index_machines_on_instance_id", using: :btree
  add_index "machines", ["ip_address"], name: "index_machines_on_ip_address", using: :btree
  add_index "machines", ["pod_id"], name: "index_machines_on_pod_id", using: :btree

  create_table "persistant_errors", force: :cascade do |t|
    t.string   "message"
    t.integer  "errorable_id"
    t.string   "errorable_type"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "pod_configs", force: :cascade do |t|
    t.integer  "fleet_config_id"
    t.text     "compose_command"
    t.text     "name"
    t.integer  "number_of_members"
    t.text     "repo_url"
    t.text     "instance_type"
    t.text     "instance_size"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.integer  "repo_id"
    t.boolean  "load_balanced"
    t.string   "compose_filename"
    t.text     "before_hooks"
    t.text     "after_hooks"
    t.string   "build_command"
    t.string   "git_ref"
    t.integer  "permanent_minimum"
  end

  create_table "pods", force: :cascade do |t|
    t.integer  "app_id"
    t.text     "name"
    t.text     "compose_command"
    t.text     "instance_type"
    t.text     "state"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.integer  "repo_id"
    t.integer  "number_of_members"
    t.integer  "fleet_id"
    t.boolean  "load_balanced"
    t.string   "compose_filename"
    t.text     "before_hooks"
    t.text     "after_hooks"
    t.string   "build_command"
    t.string   "ami"
    t.datetime "built_at"
    t.integer  "machine_image_id"
    t.string   "git_ref"
    t.integer  "builder_id"
    t.integer  "permanent_minimum"
    t.integer  "spot_amount"
    t.text     "spot_type"
    t.string   "spot_bid"
  end

  add_index "pods", ["fleet_id"], name: "index_pods_on_fleet_id", using: :btree

  create_table "repos", force: :cascade do |t|
    t.string   "repo_name"
    t.text     "url"
    t.text     "public_deploy_key"
    t.integer  "user_id"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.text     "encrypted_private_deploy_key"
    t.text     "encrypted_private_deploy_key_salt"
    t.text     "encrypted_private_deploy_key_iv"
    t.string   "type"
    t.string   "secret_key"
  end

  create_table "spot_fleet_requests", force: :cascade do |t|
    t.string   "state"
    t.string   "client_token"
    t.datetime "last_checked_at"
    t.integer  "vpc_id"
    t.integer  "app_id"
    t.string   "spot_fleet_request_id"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.integer  "instance_count"
    t.integer  "pod_id"
    t.text     "instance_types"
    t.datetime "last_history_check"
  end

  create_table "ssh_keys", force: :cascade do |t|
    t.integer  "app_id"
    t.text     "user_id"
    t.text     "public_key"
    t.boolean  "active"
    t.text     "encrypted_private_key"
    t.text     "encrypted_private_key_iv"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.text     "name"
  end

  create_table "subnets", force: :cascade do |t|
    t.integer  "vpc_id"
    t.string   "subnet_id"
    t.string   "availability_zone"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "image"
    t.string   "oauth_token"
    t.string   "oauth_secret"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "provider"
    t.string   "uid"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["provider"], name: "index_users_on_provider", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["uid"], name: "index_users_on_uid", using: :btree

  create_table "vaults", force: :cascade do |t|
    t.text     "encrypted_data"
    t.string   "name"
    t.text     "encrypted_data_salt"
    t.text     "encrypted_data_iv"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  create_table "vpcs", force: :cascade do |t|
    t.text     "name"
    t.integer  "app_id"
    t.string   "vpc_id"
    t.string   "state"
    t.string   "subnet_id"
    t.string   "availability_zone"
    t.string   "region"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

end
