module Peek
  class RedisExpiresController < ApplicationController
    before_action :restrict_non_access

    def expire
      success = true
      cache_keys = params[:cache_keys]

      begin
        # support for both arrays of cache keys and single string keys
        # TODO: investigate using expire vs delete here...
        if cache_keys.respond_to? :each
          cache_keys.flatten.each do |key|
            Rails.cache.delete_matched key
          end
        else
          Rails.cache.delete_matched cache_keys
        end
      rescue
        success = false
        flash[:error] = "Problem deleteing cache keys #{cache_keys.inspect}"
      end

      respond_to do |format|
        if success
          format.js { render 'success' }
        else
          format.js { render 'failure' }
        end
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
