# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_04_02_080000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "financial_managements", force: :cascade do |t|
    t.decimal "budgeting", precision: 5, scale: 2
    t.decimal "cashflow_management", precision: 5, scale: 2
    t.decimal "compliance", precision: 5, scale: 2
    t.datetime "created_at", null: false
    t.decimal "record_keeping", precision: 5, scale: 2
    t.decimal "total_score", precision: 5, scale: 2
    t.datetime "updated_at", null: false
  end

  create_table "hard_skills", force: :cascade do |t|
    t.decimal "attention_details", precision: 5, scale: 2
    t.decimal "collaboration_teamwork", precision: 5, scale: 2
    t.decimal "communication_skill", precision: 5, scale: 2
    t.datetime "created_at", null: false
    t.decimal "leadership", precision: 5, scale: 2
    t.decimal "problem_solving", precision: 5, scale: 2
    t.decimal "total_score", precision: 5, scale: 2
    t.datetime "updated_at", null: false
  end

  create_table "kpi_assessments", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "employment_level", null: false
    t.string "fullname", null: false
    t.string "grade", null: false
    t.decimal "overall_score", precision: 5, scale: 2
    t.string "position", null: false
    t.decimal "quality_based_total", precision: 5, scale: 2
    t.decimal "quantity_based_total", precision: 5, scale: 2
    t.string "reviewer_email"
    t.bigint "staff_profile_id", null: false
    t.datetime "updated_at", null: false
    t.index ["reviewer_email"], name: "index_kpi_assessments_on_reviewer_email"
    t.index ["staff_profile_id"], name: "index_kpi_assessments_on_staff_profile_id"
  end

  create_table "other_involvements", force: :cascade do |t|
    t.decimal "any_social_media_platform", precision: 5, scale: 2
    t.datetime "created_at", null: false
    t.decimal "ideas_platform", precision: 5, scale: 2
    t.decimal "ids_watch_column", precision: 5, scale: 2
    t.decimal "others", precision: 5, scale: 2
    t.decimal "total_score", precision: 5, scale: 2
    t.datetime "updated_at", null: false
  end

  create_table "output_and_impact_baseds", force: :cascade do |t|
    t.decimal "acceptance_of_outputs", precision: 5, scale: 2
    t.datetime "created_at", null: false
    t.decimal "number_of_involvement", precision: 5, scale: 2
    t.decimal "output_production", precision: 5, scale: 2
    t.decimal "presentation_national_level", precision: 5, scale: 2
    t.decimal "presentation_state_level", precision: 5, scale: 2
    t.decimal "total_score", precision: 5, scale: 2
    t.datetime "updated_at", null: false
    t.decimal "uptake_of_outputs", precision: 5, scale: 2
  end

  create_table "permissions", force: :cascade do |t|
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_permissions_on_code", unique: true
  end

  create_table "psychometric_assessments", primary_key: "psychometric_assessment_id", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "grade", null: false
    t.string "link_google_drive"
    t.string "name", null: false
    t.string "position", null: false
    t.bigint "staff_profile_id", null: false
    t.datetime "updated_at", null: false
    t.index ["staff_profile_id"], name: "index_psychometric_assessments_on_staff_profile_id", unique: true
  end

  create_table "quality_based_kpis", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "financial_management_id", null: false
    t.bigint "hard_skill_id", null: false
    t.bigint "other_involvement_id", null: false
    t.decimal "overall_total", precision: 5, scale: 2
    t.bigint "quarter_id", null: false
    t.bigint "research_work_id", null: false
    t.bigint "soft_skill_id", null: false
    t.datetime "updated_at", null: false
    t.index ["financial_management_id"], name: "index_quality_based_kpis_on_financial_management_id"
    t.index ["hard_skill_id"], name: "index_quality_based_kpis_on_hard_skill_id"
    t.index ["other_involvement_id"], name: "index_quality_based_kpis_on_other_involvement_id"
    t.index ["quarter_id"], name: "index_quality_based_kpis_on_quarter_id", unique: true
    t.index ["research_work_id"], name: "index_quality_based_kpis_on_research_work_id"
    t.index ["soft_skill_id"], name: "index_quality_based_kpis_on_soft_skill_id"
  end

  create_table "quantity_based_kpis", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "output_and_impact_based_id", null: false
    t.decimal "overall_total", precision: 5, scale: 2
    t.bigint "quarter_id", null: false
    t.datetime "updated_at", null: false
    t.index ["output_and_impact_based_id"], name: "index_quantity_based_kpis_on_output_and_impact_based_id"
    t.index ["quarter_id"], name: "index_quantity_based_kpis_on_quarter_id", unique: true
  end

  create_table "quarters", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "kpi_assessment_id", null: false
    t.string "quarter_name", null: false
    t.datetime "updated_at", null: false
    t.index ["kpi_assessment_id", "quarter_name"], name: "index_quarters_on_kpi_assessment_id_and_quarter_name", unique: true
    t.index ["kpi_assessment_id"], name: "index_quarters_on_kpi_assessment_id"
  end

  create_table "research_work_relateds", force: :cascade do |t|
    t.decimal "analysis_of_data", precision: 5, scale: 2
    t.datetime "created_at", null: false
    t.decimal "data_collection", precision: 5, scale: 2
    t.decimal "data_entry_and_cleaning", precision: 5, scale: 2
    t.decimal "presentation_of_findings", precision: 5, scale: 2
    t.decimal "proposal_preparation", precision: 5, scale: 2
    t.decimal "proposal_presentation", precision: 5, scale: 2
    t.decimal "report_writing", precision: 5, scale: 2
    t.decimal "total_score", precision: 5, scale: 2
    t.datetime "updated_at", null: false
  end

  create_table "role_permissions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "permission_id", null: false
    t.bigint "role_id", null: false
    t.datetime "updated_at", null: false
    t.index ["permission_id"], name: "index_role_permissions_on_permission_id"
    t.index ["role_id", "permission_id"], name: "index_role_permissions_on_role_id_and_permission_id", unique: true
    t.index ["role_id"], name: "index_role_permissions_on_role_id"
  end

  create_table "roles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_roles_on_name", unique: true
  end

  create_table "soft_skills", force: :cascade do |t|
    t.decimal "computer_skill", precision: 5, scale: 2
    t.datetime "created_at", null: false
    t.decimal "management_skill", precision: 5, scale: 2
    t.decimal "presentation_skill", precision: 5, scale: 2
    t.decimal "statistical_knowledge", precision: 5, scale: 2
    t.decimal "total_score", precision: 5, scale: 2
    t.datetime "updated_at", null: false
    t.decimal "writing_skill", precision: 5, scale: 2
  end

  create_table "staff_profiles", primary_key: "staff_profile_id", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "division", null: false
    t.string "fullname", null: false
    t.string "position", null: false
    t.string "supervisor_email", default: "", null: false
    t.string "supervisor_name", null: false
    t.datetime "updated_at", null: false
    t.index ["division"], name: "index_staff_profiles_on_division"
    t.index ["position"], name: "index_staff_profiles_on_position"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "current_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.boolean "is_active", default: true
    t.datetime "last_sign_in_at"
    t.string "last_sign_in_ip"
    t.string "name"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.bigint "role_id"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role_id"], name: "index_users_on_role_id"
  end

  add_foreign_key "kpi_assessments", "staff_profiles", primary_key: "staff_profile_id"
  add_foreign_key "psychometric_assessments", "staff_profiles", primary_key: "staff_profile_id"
  add_foreign_key "quality_based_kpis", "financial_managements"
  add_foreign_key "quality_based_kpis", "hard_skills"
  add_foreign_key "quality_based_kpis", "other_involvements"
  add_foreign_key "quality_based_kpis", "quarters"
  add_foreign_key "quality_based_kpis", "research_work_relateds", column: "research_work_id"
  add_foreign_key "quality_based_kpis", "soft_skills"
  add_foreign_key "quantity_based_kpis", "output_and_impact_baseds"
  add_foreign_key "quantity_based_kpis", "quarters"
  add_foreign_key "quarters", "kpi_assessments"
  add_foreign_key "role_permissions", "permissions"
  add_foreign_key "role_permissions", "roles"
  add_foreign_key "users", "roles"
end
