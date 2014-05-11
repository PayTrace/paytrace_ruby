module PayTrace
  # This class serves as a container for batch processing methods
  class BatchOperations
    # :nodoc:
    EXPORT_SINGLE_METHOD = "ExportBatch"
    EXPORT_MULTIPLE_METHOD = "ExportBatches"
    EXPORT_DETAILS_METHOD = "ExportBatchDetails"
    # :doc:

    # See http://help.paytrace.com/api-export-single-batch
    #
    # Verifying batch details is sometimes necessary for your application to be able to determine deposit and transaction sums. The ExportBatch method is useful for extracting a summary of a specific batch or currently pending settlement break-down by card and transaction type.
    #
    # Optional parameters hash:
    #
    # * *:batch_number* -- number of the batch of transactions you wish to export
    def self.export_single(params = {})
      PayTrace::API::Gateway.send_request(EXPORT_SINGLE_METHOD, params, [], [:batch_number])
    end

    # See http://help.paytrace.com/api-export-batches
    #
    # Exports summary information about multiple batches over a given date range. Required parameters:
    #
    # * *:start_date* -- indicates when to start searching for transactions to export. Must be a valid date formatted as MM/DD/YYYY
    # * *:end_date* -- indicates when to end searching for transactions to export. Must be a valid date formatted as MM/DD/YYYY
    def self.export_multiple(params = {})
      PayTrace::API::Gateway.send_request(EXPORT_MULTIPLE_METHOD, params, [:start_date, :end_date])
    end

    # See http://help.paytrace.com/api-export-batch-details
    #
    # Exports transaction details of a given batch. Required parameters hash:
    #
    # * *:batch_number* -- number of the batch of transactions you wish to export
    def self.export_details(params = {})
      PayTrace::API::Gateway.send_request(EXPORT_DETAILS_METHOD, params, [:batch_number])
    end
  end
end