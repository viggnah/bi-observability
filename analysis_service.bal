import ballerina/http;
import ballerina/log;
import ballerina/io;
import ballerina/lang.regexp;
import ballerina/random;
import ballerina/time;

// Analysis service running on port 8082
@display {
    label: "Analysis Service"
}
service /analysis on new http:Listener(8082) {

    function init() {
        log:printInfo("Analysis service started on port 8082");
    }

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
        string|io:Error csvContent = io:fileReadString("./data/analytics.csv");
        
        if csvContent is io:Error {
            log:printError(string `Failed to read analytics CSV file: ${csvContent.message()}`);
            return error("Failed to read analytics data");
        }

        // Parse CSV and convert to JSON structure
        string[] lines = regexp:split(re `\n`, csvContent);
        AnalyticsData[] analyticsData = [];
        decimal totalAmount = 0.0;
        int completedTransactions = 0;
        int pendingTransactions = 0;
        int failedTransactions = 0;
        
        foreach int i in 1..<lines.length() {
            if lines[i].trim() == "" {
                continue;
            }
            
            string[] fields = regexp:split(re `,`, lines[i]);
            
            if fields.length() >= 5 {
                int csvCustomerId = check int:fromString(fields[0]);
                
                if csvCustomerId == customerId {
                    decimal amount = check decimal:fromString(fields[2]);
                    string status = fields[4];
                    
                    AnalyticsData data = {
                        customerId: csvCustomerId,
                        productType: fields[1],
                        amount: amount,
                        transactionDate: fields[3],
                        status: status
                    };
                    
                    analyticsData.push(data);
                    totalAmount += amount;
                    
                    // Count transactions by status
                    if status == "completed" {
                        completedTransactions += 1;
                    } else if status == "pending" {
                        pendingTransactions += 1;
                    } else if status == "failed" {
                        failedTransactions += 1;
                    }
                }
            }
        }
        
        if analyticsData.length() == 0 {
            log:printInfo(string `No analytics data found for customer - Customer ID: ${customerId}`);
            return {message: string `No analytics data found for customer ID ${customerId}`};
        }

        // Calculate aggregated metrics
        AnalyticsSummary summary = {
            totalTransactions: analyticsData.length(),
            totalAmount: totalAmount,
            completedTransactions: completedTransactions,
            pendingTransactions: pendingTransactions,
            failedTransactions: failedTransactions,
            averageTransactionAmount: totalAmount / <decimal>analyticsData.length()
        };

        log:printInfo(string `Analytics data processed successfully - Customer ID: ${customerId}, Total transactions: ${analyticsData.length()}`);
        
        return {
            customerId: customerId,
            data: analyticsData,
            summary: summary,
            generatedAt: time:utcToString(time:utcNow())
        };
    }

    // Get aggregated analytics for all customers
    resource function get analytics/summary() returns GlobalAnalyticsResponse|error {
        
        log:printInfo("Received request for global analytics summary");
        
        // Simulate heavy processing
        int delay = check random:createIntInRange(500, 1500);
        
        // Read analytics CSV file
        string|io:Error csvContent = io:fileReadString("./data/analytics.csv");
        
        if csvContent is io:Error {
            log:printError(string `Failed to read analytics CSV file: ${csvContent.message()}`);
            return error("Failed to read analytics data");
        }

        // Parse and aggregate all data
        string[] lines = regexp:split(re `\n`, csvContent);
        map<decimal> customerTotals = {};
        map<int> productTypeCounts = {};
        decimal grandTotal = 0.0;
        int totalTransactions = 0;
        
        foreach int i in 1..<lines.length() {
            if lines[i].trim() == "" {
                continue;
            }
            
            string[] fields = regexp:split(re `,`, lines[i]);
            
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