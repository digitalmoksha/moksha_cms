# Version of the SuperMemo algorithm: http://www.supermemo.com/english/ol/sm2.htm
# Based on : https://github.com/espresse/spaced_repetition
#   which he modified for a 0-3 quality scale (instead of 0-5)
#
# answer_quality: 0 -> (no clue), 1 -> wrong, 2 -> correct, 3 -> memorized
#
# Easiness factor values for original (5-based) and modified (3-based)
# 5 based:  0 -> -0.80, 1 -> -0.54, 2 -> -0.32, 3 -> -0.14, 4 -> 0.0, 5 -> 0.1
# 3 based:  0 -> -0.80, 1 -> -0.30, 2 -> 0.0,   3 -> 0.1
require 'date'

#------------------------------------------------------------------------------
module DmLms
  module Concerns
    module SpacedRepetitionSm2
      extend ActiveSupport::Concern

      included do

        #------------------------------------------------------------------------------
        def spaced_repetition(answer_quality, prev_interval = 0, prev_ef = 2.5)
          #--- if answer_quality is below 2 start repetition from the begining, 
          # without changing easiness_factor
          if answer_quality < 2
            @efactor   = prev_ef
            @interval  = 0
          else
            @efactor   = calculate_easiness_factor(answer_quality, prev_ef)
            @interval  = calculate_interval(answer_quality, prev_interval, prev_ef)
          end
        
          @due_on = calculate_date(@interval)
        end

      private

        #------------------------------------------------------------------------------
        def calculate_interval(answer_quality, prev_interval, prev_ef)
          if prev_interval == 0
            calculated_interval = (answer_quality == 3 ? 6 : 1)
          elsif prev_interval == 1
            calculated_interval = 6
          else
            calculated_interval = (prev_interval * prev_ef).to_i
          end
        end

        #------------------------------------------------------------------------------
        def calculate_easiness_factor(answer_quality, prev_ef)
          calculated_ef = prev_ef + (0.1 - (3 - answer_quality) * ((3 - answer_quality) * 0.1))
          calculated_ef = 1.3 if calculated_ef < 1.3
          calculated_ef
        end

        #------------------------------------------------------------------------------
        def calculate_date(interval)
          Date.today + interval
        end
      end
    end
  end
end