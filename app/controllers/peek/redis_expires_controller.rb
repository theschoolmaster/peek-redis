module Peek
  class RedisExpiresController < ApplicationController
    before_action :restrict_non_access

    def expire
      cache_keys = params[:cache_keys]

      cache_keys.each do |key|
        # TODO: investigate using expire vs delete here...
        Rails.cache.delete key
      end

      respond_to do |format|
        format.js { render 'success' }
      end
    end

    private

    def restrict_non_access
      unless peek_enabled?
        raise ActionController::RoutingError.new('Not Found')
      end
    end
  end
end
