# frozen_string_literal: true

class RemoveDeprecatedIdsStaffPermissions < ActiveRecord::Migration[8.1]
  DEPRECATED_PERMISSIONS = [
    'master_data.ids_staffs.index',
    'master_data.ids_staff.index'
  ].freeze

  def up
    return unless table_exists?(:permissions)

    quoted_codes = DEPRECATED_PERMISSIONS.map { |code| connection.quote(code) }.join(', ')

    safety_assured do
      execute <<~SQL.squish
        DELETE FROM role_permissions
        WHERE permission_id IN (
          SELECT id FROM permissions WHERE code IN (#{quoted_codes})
        )
      SQL

      execute <<~SQL.squish
        DELETE FROM permissions
        WHERE code IN (#{quoted_codes})
      SQL
    end
  end

  def down
    return unless table_exists?(:permissions)

    safety_assured do
      execute <<~SQL
        INSERT INTO permissions (code, name, created_at, updated_at)
        VALUES ('master_data.ids_staffs.index', 'View IDS Staff', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
        ON CONFLICT (code) DO NOTHING
      SQL

      execute <<~SQL
        INSERT INTO permissions (code, name, created_at, updated_at)
        VALUES ('master_data.ids_staff.index', 'View IDS Staff', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
        ON CONFLICT (code) DO NOTHING
      SQL
    end
  end
end
