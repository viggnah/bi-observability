// Account information with balance
public type Account record {|
    int account_id;
    int customer_id;
    string account_type;
    decimal balance;
    string created_at;
|};

// Transaction information
public type Transaction record {|
    int transaction_id;
    int account_id;
    decimal amount;
    string txn_type;
    string txn_time;
|};

// Response for customer accounts
public type CustomerAccountsResponse record {|
    int customerId;
    Account[] accounts;
|};

// Response for customer transactions
public type CustomerTransactionsResponse record {|
    int customerId;
    Transaction[] transactions;
|};

// Customer details from Customer Service
public type CustomerDetails record {|
    int customerId;
    string name;
    string email;
    int age;
    string city;
    string country;
|};

// Analytics data types
public type AnalyticsData record {|
    int customerId;
    string productType;
    decimal amount;
    string transactionDate;
    string status;
|};

public type AnalyticsSummary record {|
    int totalTransactions;
    decimal totalAmount;
    int completedTransactions;
    int pendingTransactions;
    int failedTransactions;
    decimal averageTransactionAmount;
|};

public type AnalyticsResponse record {|
    int customerId;
    AnalyticsData[] data;
    AnalyticsSummary summary;
    string generatedAt;
|};

// Global analytics response
public type GlobalAnalyticsResponse record {|
    int totalTransactions;
    decimal grandTotal;
    map<decimal> customerTotals;
    map<int> productTypeCounts;
    string generatedAt;
|};

// Comprehensive customer profile response
public type CustomerProfileResponse record {|
    int customerId;
    CustomerDetails customerDetails;
    Account[] accounts;
    AnalyticsResponse analyticsData;
    decimal processingTime;
    string retrievedAt;
|};

// Health status response
public type HealthStatus record {|
    string status;
    string database;
    string customerService;
    string analyticsService;
    string timestamp;
|};

// Error response
public type ErrorResponse record {|
    string message;
|};
