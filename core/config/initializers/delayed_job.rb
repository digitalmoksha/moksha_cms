# frozen_string_literal: true
require 'delayed_job'

Rails.application.config.active_job.queue_adapter = :delayed_job

Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.max_attempts = 3
Delayed::Worker.max_run_time = 4.hours
Delayed::Worker.default_queue_name = 'default'
