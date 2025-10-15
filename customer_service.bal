import ballerina/http;
import ballerina/log;
import ballerina/io;
import ballerina/random;
import ballerina/time;

// Customer service running on port 8081
@display {
    label: "Customer Service"
}
service /customer on new http:Listener(8081) {

    // Get customer details from CSV file
    resource function get customers/[int customerId]() returns CustomerDetails|ErrorResponse|error {
        
        log:printInfo(string `Received request for customer details - Customer ID: ${customerId}`);
        
        // Simulate random network delay
        int delay = check random:createIntInRange(100, 500);
        
        // Actually simulate delay with busy wait (Ballerina doesn't have sleep)
        log:printDebug(string `Simulating network delay of ${delay}ms for customer ${customerId}`);
        time:Utc startTime = time:utcNow();
        decimal delaySeconds = <decimal>delay / 1000.0d;
        while (time:utcDiffSeconds(time:utcNow(), startTime) < delaySeconds) {
            // Busy wait to simulate processing delay
        }
        
        // Simulate failure scenario (10% chance)
        int failureChance = check random:createIntInRange(1, 10);
        if failureChance == 1 {
            log:printError(string `Simulated network failure for customer ${customerId}`);
            return error("Network timeout - Customer service unreachable");
        }

        // Read customer data from CSV using stream
        string csvFilePath = "./data/customers.csv";
        stream<CustomerDetails, io:Error?> csvStream = check io:fileReadCsvAsStream(csvFilePath);
        
        // Search for customer in the CSV stream
        CustomerDetails[]|io:Error customers = from CustomerDetails customer in csvStream
                                     where customer.customerId == customerId
                                     select customer;
        
        if customers is io:Error {
            log:printError(string `Failed to read customers CSV file: ${customers.message()}`);
            return error("Failed to read customer data");
        }
        
        if customers.length() > 0 {
            CustomerDetails foundCustomer = customers[0];
            log:printInfo(string `Customer found in CSV - Customer ID: ${customerId}, Name: ${foundCustomer.name}`);
            return foundCustomer;
        }
        
        log:printInfo(string `Customer not found in CSV - Customer ID: ${customerId}`);
        return {message: string `Customer with ID ${customerId} not found`};
    }

    // Health check endpoint
    resource function get health() returns string {
        return "Customer Service is healthy";
    }

    // Simulate service failure for testing
    resource function post simulate/failure() returns http:InternalServerError {
        log:printError("Simulated service failure triggered");
        return {
            body: {
                "error": "Simulated internal server error",
                "timestamp": time:utcToString(time:utcNow())
            }
        };
    }
}