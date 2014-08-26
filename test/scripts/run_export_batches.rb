$:<< "./lib" # uncomment this to run against a Git clone instead of an installed gem

require "paytrace"
require "paytrace/debug"
require 'io/console'

# change this as needed to reflect the username, password, and test host you're testing against
PayTrace::Debug.configure_test("demo123", "demo123", "stage.paytrace.com")

# export summary info of a single batch (by batch number in this case, otherwise chooses latest batch)
PayTrace::Debug.trace do
  params = {
    batch_number: 413
  }
  result = PayTrace::BatchOperations.export_single(params)
end

# export batches by date range
PayTrace::Debug.trace do
  params = {
    start_date: "01/01/2014",
    end_date: "05/01/2014"
  }
  result = PayTrace::BatchOperations.export_multiple(params)
end

#THIS TAKES A LONG TIME COMMENTING OUT.
# export batch transaction details
# PayTrace::Debug.trace do
#   params = {
#     batch_number: 413
#   }
#   puts "About to export transaction details for batch number #{params[:batch_number]}..."
#   STDIN.getc
#   result = PayTrace::BatchOperations.export_details(params)
# end
