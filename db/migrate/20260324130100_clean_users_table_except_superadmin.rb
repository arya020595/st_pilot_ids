# frozen_string_literal: true

class CleanUsersTableExceptSuperadmin < ActiveRecord::Migration[8.1]
  def up
    # Keep only the superadmin user, delete all others
    safety_assured do
      execute <<~SQL
        DELETE FROM users
        WHERE email <> 'admin@pilotids.com';
      SQL
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration, 'Deleted users cannot be restored automatically'
  end
end
