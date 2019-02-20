module Peek
  class RedisExpiresController < ApplicationController
    before_action :restrict_non_access

    def expire
      cache_keys = params[:cache_keys]

      # support for both arrays of cache keys and single string keys
      # TODO: investigate using expire vs delete here...
      if cache_keys.respond_to? :each
        cache_keys.flatten.each do |key|
          Rails.cache.delete_matched key
        end
      else
        Rails.cache.delete_matched cache_keys
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
