module PayTrace
  # This class serves as a container for batch processing methods
  class BatchOperations
    EXPORT_SINGLE_METHOD = "ExportBatch"
    EXPORT_MULTIPLE_METHOD = "ExportBatches"
    EXPORT_DETAILS_METHOD = "ExportBatchDetails"

    # See http://help.paytrace.com/api-export-single-batch
    #
    # Verifying batch details is sometimes necessary for your application to be able to determine deposit and transaction sums. The ExportBatch method is useful for extracting a summary of a specific batch or currently pending settlement break-down by card and transaction type.
    #
    # Optional parameters hash:
    #
    # * *:batch_number* -- number of the batch of transactions you wish to export
    def self.exportSingle(params = {})
      PayTrace::API::Gateway.send_request(EXPORT_SINGLE_METHOD, [:batch_number], params)
    end

    # See http://help.paytrace.com/api-export-batches
    #
    # Exports summary information about multiple batches over a given date range. Required parameters:
    #
    # * *:start_date* -- indicates when to start searching for transactions to export. Must be a valid date formatted as MM/DD/YYYY
    # * *:end_date* -- indicates when to end searching for transactions to export. Must be a valid date formatted as MM/DD/YYYY
    def self.exportMultiple(params = {})
      PayTrace::API::Gateway.send_request(EXPORT_MULTIPLE_METHOD, [:start_date, :end_date], params)
    end

    # See http://help.paytrace.com/api-export-batch-details
    #
    # Exports transaction details of a given batch. Required parameters hash:
    #
    # * *:batch_number* -- number of the batch of transactions you wish to export
    def self.exportDetails(params = {})
      PayTrace::API::Gateway.send_request(EXPORT_DETAILS_METHOD, [:batch_number], params)
    end
  end
end