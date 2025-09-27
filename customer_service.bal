import ballerina/http;
import ballerina/log;
import ballerina/io;
import ballerina/lang.regexp;
import ballerina/random;
import ballerina/time;

// Customer service running on port 8081
@display {
    label: "Customer Service"
}
service /customer on new http:Listener(8081) {

    function init() {
        log:printInfo("Customer service started on port 8081");
    }

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

        // Read customer data from CSV
        string|io:Error csvContent = io:fileReadString("./data/customers.csv");
        
        if csvContent is io:Error {
            log:printError(string `Failed to read customer CSV file: ${csvContent.message()}`);
            return error("Failed to read customer data");
        }

        // Parse CSV content
        string[] lines = regexp:split(re `\n`, csvContent);
        
        foreach int i in 1..<lines.length() {
            if lines[i].trim() == "" {
                continue;
            }
            
            string[] fields = regexp:split(re `,`, lines[i]);
            
            if fields.length() >= 6 {
                int csvCustomerId = check int:fromString(fields[0]);
                
                if csvCustomerId == customerId {
                    log:printInfo(string `Customer found in CSV - Customer ID: ${customerId}, Name: ${fields[1]}`);
                    
                    return {
                        customerId: csvCustomerId,
                        name: fields[1],
                        email: fields[2],
                        age: check int:fromString(fields[3]),
                        city: fields[4],
                        country: fields[5]
                    };
                }
            }
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