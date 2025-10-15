import ballerina/http;
import ballerina/log;
import ballerina/io;
import ballerina/random;
import ballerina/time;

// Analysis service running on port 8082
@display {
    label: "Analysis Service"
}
service /analysis on new http:Listener(8082) {

    // Get analytics data and transform CSV to JSON
    resource function get analytics/[int customerId]() returns AnalyticsResponse|ErrorResponse|error {
        
        log:printInfo(string `Received request for analytics data - Customer ID: ${customerId}`);
        
        // Simulate processing time
        int delay = check random:createIntInRange(200, 800);
        
        // Actually simulate processing delay
        log:printDebug(string `Simulating processing delay of ${delay}ms for customer ${customerId}`);
        time:Utc startTime = time:utcNow();
        decimal delaySeconds = <decimal>delay / 1000.0d;
        while (time:utcDiffSeconds(time:utcNow(), startTime) < delaySeconds) {
            // Busy wait to simulate processing delay
        }
        
        // Simulate failure scenario (15% chance for analytics complexity)
        int failureChance = check random:createIntInRange(1, 100);
        if failureChance <= 15 {
            log:printError(string `Simulated analytics processing failure for customer ${customerId}`);
            return error("Analytics processing failed - data transformation error");
        }

        // Read analytics CSV file
        string csvFilePath = "./data/analytics.csv";
        stream<AnalyticsData, io:Error?> csvStream = check io:fileReadCsvAsStream(csvFilePath);
        
        // Search for customer in the CSV stream
        AnalyticsData[]|error analytics =  from AnalyticsData data in csvStream
                                     where data.customerId == customerId
                                     select data;

        if analytics is error {
            log:printError(string `Failed to read analytics CSV file: ${analytics.message()}`);
            return error("Failed to read analytics data");
        }

        if analytics.length() == 0 {
            log:printInfo(string `No analytics data found for customer - Customer ID: ${customerId}`);
            return {message: string `No analytics data found for customer ID ${customerId}`};
        }

        decimal totalAmount = 0.0;
        int completedTransactions = 0;
        int pendingTransactions = 0;
        int failedTransactions = 0;

        foreach int i in 1..<analytics.length() {
            totalAmount += analytics[i].amount;
            
            // Count transactions by status
            if analytics[i].status == "completed" {
                completedTransactions += 1;
            } else if analytics[i].status == "pending" {
                pendingTransactions += 1;
            } else if analytics[i].status == "failed" {
                failedTransactions += 1;
            }
        }
        
        // Calculate aggregated metrics
        AnalyticsSummary summary = {
            totalTransactions: analytics.length(),
            totalAmount: totalAmount,
            completedTransactions: completedTransactions,
            pendingTransactions: pendingTransactions,
            failedTransactions: failedTransactions,
            averageTransactionAmount: totalAmount / <decimal>analytics.length()
        };

        log:printInfo(string `Analytics data processed successfully - Customer ID: ${customerId}, Total transactions: ${analytics.length()}`);
        
        return {
            customerId: customerId,
            data: analytics,
            summary: summary,
            generatedAt: time:utcToString(time:utcNow())
        };
    }

    // Get aggregated analytics for all customers
    resource function get analytics/summary() returns GlobalAnalyticsResponse|error {
        
        log:printInfo("Received request for global analytics summary");
        
        // Simulate heavy processing
        int delay = check random:createIntInRange(500, 1500);

        // Actually simulate processing delay
        log:printDebug(string `Simulating processing delay of ${delay}ms for analytics summary`);
        time:Utc startTime = time:utcNow();
        decimal delaySeconds = <decimal>delay / 1000.0d;
        while (time:utcDiffSeconds(time:utcNow(), startTime) < delaySeconds) {
            // Busy wait to simulate processing delay
        }
        
        // Read analytics CSV file
        string[][]|io:Error csvContent = io:fileReadCsv("./data/analytics.csv");
        
        if csvContent is io:Error {
            log:printError(string `Failed to read analytics CSV file: ${csvContent.message()}`);
            return error("Failed to read analytics data");
        }

        // Parse and aggregate all data
        map<decimal> customerTotals = {};
        map<int> productTypeCounts = {};
        decimal grandTotal = 0.0;
        int totalTransactions = 0;
        
        foreach int i in 1..<csvContent.length() {
            if csvContent[i].length() == 0 {
                continue;
            }

            string[] fields = csvContent[i];

            if fields.length() >= 5 {
                string customerKey = fields[0];
                string productType = fields[1];
                decimal amount = check decimal:fromString(fields[2]);
                
                // Aggregate by customer
                if customerTotals.hasKey(customerKey) {
                    customerTotals[customerKey] = <decimal>customerTotals[customerKey] + amount;
                } else {
                    customerTotals[customerKey] = amount;
                }
                
                // Count by product type
                if productTypeCounts.hasKey(productType) {
                    productTypeCounts[productType] = <int>productTypeCounts[productType] + 1;
                } else {
                    productTypeCounts[productType] = 1;
                }
                
                grandTotal += amount;
                totalTransactions += 1;
            }
        }

        log:printInfo(string `Global analytics summary generated - Total transactions: ${totalTransactions}, Grand total: ${grandTotal}`);
        
        return {
            totalTransactions: totalTransactions,
            grandTotal: grandTotal,
            customerTotals: customerTotals,
            productTypeCounts: productTypeCounts,
            generatedAt: time:utcToString(time:utcNow())
        };
    }

    // Health check endpoint
    resource function get health() returns string {
        return "Analytics Service is healthy";
    }
}