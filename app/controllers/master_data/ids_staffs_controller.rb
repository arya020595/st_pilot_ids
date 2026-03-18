# frozen_string_literal: true

module MasterData
  # Controller for IDS Staff listing under Master Data.
  class IdsStaffsController < ApplicationController
    def index
      authorize :ids_staff, :index?, policy_class: MasterData::IdsStaffPolicy

      @q = policy_scope(IdsStaff, policy_scope_class: MasterData::IdsStaffPolicy::Scope)
           .order(code: :asc)
           .ransack(params[:q])

      @per_page = sanitize_per_page(params[:per_page])
      @pagy, @ids_staffs = pagy(@q.result, limit: @per_page)
    end

    private

    def sanitize_per_page(value)
      per_page = value.to_i
      allowed_limits = [10, 25, 50, 100]

      allowed_limits.include?(per_page) ? per_page : 10
    end
  end
end
