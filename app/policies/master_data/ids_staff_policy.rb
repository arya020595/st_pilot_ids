# frozen_string_literal: true

module MasterData
  class IdsStaffPolicy < ApplicationPolicy
    # Permission codes:
    # - master_data.ids_staffs.index

    private

    def permission_resource
      'master_data.ids_staffs'
    end

    class Scope < ApplicationPolicy::Scope
      private

      def permission_resource
        'master_data.ids_staffs'
      end
    end
  end
end
