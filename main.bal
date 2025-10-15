import ballerina/http;
import ballerina/log;
import ballerina/sql;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;
import ballerinax/prometheus as _;
import ballerinax/jaeger as _;
import ballerina/time;

// configuration
configurable string dbHost = ?;
configurable string dbUser = ?;
configurable string dbPassword = ?;
configurable string dbName = ?;
configurable int dbPort = ?;
configurable string customerServiceUrl = ?;
configurable string analyticsServiceUrl = ?;

// Initialize MySQL client
final mysql:Client dbClient = check new (
    host = dbHost,
    user = dbUser,
    password = dbPassword,
    database = dbName,
    port = dbPort
);

// HTTP clients for other services
final http:Client customerServiceClient = check new (customerServiceUrl);
final http:Client analyticsServiceClient = check new (analyticsServiceUrl);

// HTTP service to expose banking operations
@display {
    label: "Banking Service"
}
service /banking on new http:Listener(8080) {

    // Get all accounts with balances for a customer
    resource function get customers/[int customerId]/accounts() returns CustomerAccountsResponse|ErrorResponse|error {
        
        log:printInfo("Received request for customer accounts - Customer ID: " + customerId.toString());

        // Query to get all accounts for the customer
        sql:ParameterizedQuery query = `
            SELECT account_id, customer_id, account_type, balance, created_at 
            FROM accounts 
            WHERE customer_id = ${customerId}
        `;

        stream<Account, sql:Error?> accountStream = dbClient->query(query);
        Account[] accounts = [];

        do {
            check from Account accountRecord in accountStream
                do {
                    accounts.push(accountRecord);
                };
        } on fail error e {
            log:printError("Database query failed for customer accounts - Customer ID: " + customerId.toString() + ", Error: " + e.message());
            return error("Database operation failed");
        }

        if accounts.length() == 0 {
            log:printInfo("No accounts found for customer - Customer ID: " + customerId.toString());
            return {message: "No accounts found for customer ID: " + customerId.toString()};
        }

        log:printInfo("Successfully retrieved customer accounts - Customer ID: " + customerId.toString() + ", Account count: " + accounts.length().toString());

        return {
            customerId: customerId,
            accounts: accounts
        };
    }

    // Get transaction history for all accounts of a customer
    resource function get customers/[int customerId]/transactions() returns CustomerTransactionsResponse|ErrorResponse|error {
        
        log:printInfo("Received request for customer transactions - Customer ID: " + customerId.toString());

        // Query to get all transactions for customer's accounts
        sql:ParameterizedQuery query = `
            SELECT t.transaction_id, t.account_id, t.amount, t.txn_type, t.txn_time
            FROM transactions t
            INNER JOIN accounts a ON t.account_id = a.account_id
            WHERE a.customer_id = ${customerId}
            ORDER BY t.txn_time DESC
        `;

        stream<Transaction, sql:Error?> transactionStream = dbClient->query(query);
        Transaction[] transactions = [];

        do {
            check from Transaction txnRecord in transactionStream
                do {
                    transactions.push(txnRecord);
                };
        } on fail error e {
            log:printError("Database query failed for customer transactions - Customer ID: " + customerId.toString() + ", Error: " + e.message());
            return error("Database operation failed");
        }

        if transactions.length() == 0 {
            log:printInfo("No transactions found for customer - Customer ID: " + customerId.toString());
            return {message: "No transactions found for customer ID: " + customerId.toString()};
        }

        log:printInfo("Successfully retrieved customer transactions - Customer ID: " + customerId.toString() + ", Transaction count: " + transactions.length().toString());

        return {
            customerId: customerId,
            transactions: transactions
        };
    }

    // Comprehensive customer profile that calls all services
    resource function get customers/[int customerId]/profile() returns CustomerProfileResponse|ErrorResponse|error {
        
        log:printInfo(string `Received request for complete customer profile - Customer ID: ${customerId}`);
        
        // Start timing for performance monitoring
        time:Utc startTime = time:utcNow();
        
        // Call customer service for personal details
        CustomerDetails|error customerDetails = customerServiceClient->get(string `/customers/${customerId}`);
        
        if customerDetails is error {
            log:printError(string `Failed to get customer details from Customer Service - Customer ID: ${customerId}, Error: ${customerDetails.message()}`);
            return {message: string `Failed to retrieve customer details: ${customerDetails.message()}`};
        }
        
        // Call analytics service for analytics data
        AnalyticsResponse|error analyticsData = analyticsServiceClient->get(string `/analytics/${customerId}`);
        
        if analyticsData is error {
            log:printError(string `Failed to get analytics data from Analytics Service - Customer ID: ${customerId}, Error: ${analyticsData.message()}`);
            return {message: string `Failed to retrieve analytics data: ${analyticsData.message()}`};
        }
        
        // Get account data from database
        sql:ParameterizedQuery accountQuery = `
            SELECT account_id, customer_id, account_type, balance, created_at 
            FROM accounts 
            WHERE customer_id = ${customerId}
        `;

        stream<Account, sql:Error?> accountStream = dbClient->query(accountQuery);
        Account[] accounts = [];

        do {
            check from Account accountRecord in accountStream
                do {
                    accounts.push(accountRecord);
                };
        } on fail error e {
            log:printError(string `Database query failed for customer profile - Customer ID: ${customerId}, Error: ${e.message()}`);
            return error("Database operation failed");
        }
        
        // Calculate performance metrics
        time:Utc endTime = time:utcNow();
        decimal processingTime = time:utcDiffSeconds(endTime, startTime);
        
        log:printInfo(string `Successfully retrieved complete customer profile - Customer ID: ${customerId}, Processing time: ${processingTime} seconds`);
        
        return {
            customerId: customerId,
            customerDetails: customerDetails,
            accounts: accounts,
            analyticsData: analyticsData,
            processingTime: processingTime,
            retrievedAt: time:utcToString(endTime)
        };
    }

    // Health check endpoint (no tracing to reduce noise)
    @http:ResourceConfig {
        produces: ["application/json"]
    }
    resource function get health() returns HealthStatus {
        
        // Check database connectivity
        boolean dbHealthy = true;
        sql:ParameterizedQuery healthQuery = `SELECT 1`;
        
        sql:ExecutionResult|error result = dbClient->queryRow(healthQuery);
        if (result is error) {
            dbHealthy = false;
        }
    
        // Check downstream services
        boolean customerServiceHealthy = true;
        boolean analyticsServiceHealthy = true;
        
        do {
            string|error customerHealth = customerServiceClient->get("/health");
            if customerHealth is error {
                customerServiceHealthy = false;
            }
        } on fail {
            customerServiceHealthy = false;
        }
        
        do {
            string|error analyticsHealth = analyticsServiceClient->get("/health");
            if analyticsHealth is error {
                analyticsServiceHealthy = false;
            }
        } on fail {
            analyticsServiceHealthy = false;
        }
        
        boolean overallHealth = dbHealthy && customerServiceHealthy && analyticsServiceHealthy;
        
        return {
            status: overallHealth ? "healthy" : "unhealthy",
            database: dbHealthy ? "connected" : "disconnected",
            customerService: customerServiceHealthy ? "available" : "unavailable",
            analyticsService: analyticsServiceHealthy ? "available" : "unavailable",
            timestamp: time:utcToString(time:utcNow())
        };
    }
}
