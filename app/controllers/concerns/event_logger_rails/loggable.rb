# frozen_string_literal: true

module EventLoggerRails
  ##
  # Provides event logging with relevant controller/request data.
  module Loggable
    extend ActiveSupport::Concern

    def log_event(level, event, **data)
      data_to_log = data_from_request.merge(data)
      EventLoggerRails.log(level, event, **data_to_log)
    rescue EventLoggerRails::Exceptions::UnregisteredEvent => e
      log_event :error, 'event_logger_rails.event.unregistered', message: e.message
    rescue EventLoggerRails::Exceptions::InvalidLoggerLevel => e
      log_event :error, 'event_logger_rails.logger_level.invalid', message: e.message
    end

    def data_from_request
      {
        controller: controller_name.camelcase,
        action: action_name,
        method: request.method,
        path: request.path,
        remote_ip: request.remote_ip,
        parameters: request.query_parameters.to_json
      }
    end
  end
end
