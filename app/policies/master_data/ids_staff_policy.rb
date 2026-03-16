# frozen_string_literal: true

module MasterData
  # Authorization policy for IDS Staff access under Master Data.
  class IdsStaffPolicy < ApplicationPolicy
    # Permission codes:
    # - master_data.ids_staffs.index

    private

    def permission_resource
      'master_data.ids_staffs'
    end

    # Scope for IDS Staff queries under Master Data.
    class Scope < ApplicationPolicy::Scope
      private

      def permission_resource
        'master_data.ids_staffs'
      end
    end
  end
end
