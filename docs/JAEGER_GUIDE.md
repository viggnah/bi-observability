# Jaeger Tracing Analysis Guide

## Quick Start Testing
```bash
./test_jaeger_tracing.sh
```

## Jaeger UI Navigation (http://localhost:16686)

### 1. Finding Your Traces
- **Service Selection**: Choose `viggnah/dbandlogging2` (your banking service)
- **Operation Filter**: 
  - `get /customers/{customerId}/profile` - Full customer profile
  - `get /customers/{customerId}/accounts` - Account data
  - `get /health` - Health checks
- **Time Range**: Set to "Last 15 minutes" or custom range
- **Limit Results**: Start with 20-50 traces

### 2. Advanced Filtering
- **By Status**: `http.status_code=500` for errors, `=200` for success
- **By Duration**: Set minimum (e.g., >100ms) to find slow requests
- **By Tags**: 
  - `customer.id=1001` - Specific customer
  - `error=true` - Error traces only
  - `component=mysql` - Database operations

### 3. Understanding Trace Structure

#### Successful Cross-Service Call Pattern:
```
Banking Service (8080)
├── GET /customers/1001/profile
    ├── HTTP GET → Customer Service (8081)
    │   ├── CSV Processing
    │   └── Simulated Delay (100-500ms)
    ├── HTTP GET → Analysis Service (8082)
    │   ├── JSON Processing
    │   └── Simulated Delay (200-800ms)
    └── MySQL Query → Account/Transaction data
```

#### Error Trace Pattern:
```
Banking Service (8080)
├── GET /customers/9999/profile
    ├── HTTP GET → Customer Service (8081) ❌ 404 Not Found
    ├── HTTP GET → Analysis Service (8082) ❌ No Data
    └── MySQL Query → Empty Results ⚠️
```

### 4. Key Metrics to Analyze

#### Performance Metrics:
- **End-to-End Latency**: Total trace duration
- **Service Breakdown**: Which service takes longest
- **Database Time**: MySQL query duration
- **Network Latency**: Time between service calls

#### Error Analysis:
- **Error Propagation**: How errors flow between services
- **Failure Points**: Which service fails first
- **Recovery Behavior**: How services handle downstream failures

### 5. Reducing Health Check Noise

Current issue: Health checks create many traces. Solutions:

#### Option 1: Filter Out Health Checks
In Jaeger UI:
- Add tag filter: `operation!=/health`
- Or use operation filter and exclude health operations

#### Option 2: Optimize Health Check Implementation
```ballerina
// Consider making health checks less frequent or disabling tracing
@http:ResourceConfig {
    observability: false  // This would disable tracing for health endpoint
}
resource function get health() returns json {
    // health check logic
}
```

## Common Troubleshooting Scenarios

### Scenario 1: Customer Profile Slow
1. **Search**: Service=`viggnah/dbandlogging2`, Operation=`/customers/{id}/profile`
2. **Sort by**: Duration (descending)
3. **Look for**: Which span takes longest
4. **Common causes**: 
   - Database query slow
   - Customer service delay simulation
   - Analysis service processing

### Scenario 2: Random Failures
1. **Filter**: `http.status_code=500` or `error=true`
2. **Pattern analysis**: Check if failures are truly random or have patterns
3. **Error details**: Click on error spans to see error messages
4. **Correlation**: Check if multiple services fail together

### Scenario 3: Database Connection Issues
1. **Search for**: Tags containing `mysql` or `database`
2. **Look for**: Connection timeout errors or slow queries
3. **Pattern**: Multiple services affected simultaneously

## Correlation with Other Tools

### Prometheus Metrics (http://localhost:9090)
Query examples:
```promql
# HTTP request rate
rate(http_requests_total[5m])

# Error rate
rate(http_requests_total{status=~"5.."}[5m])

# Request duration
histogram_quantile(0.95, http_request_duration_seconds_bucket)
```

### Grafana Dashboards (http://localhost:3000)
- Import Jaeger dashboard for service maps
- Create custom dashboards correlating metrics with trace data
- Set up alerts based on error rates or latency

## Best Practices

### 1. Trace Sampling
- Production: Use adaptive sampling (1-10%)
- Development: Can use 100% sampling
- Configure via `observabilityConfig.toml`

### 2. Custom Span Tags
Add meaningful tags:
```ballerina
// In your service code
observability:addTag("customer.id", customerId);
observability:addTag("operation.type", "profile_aggregation");
```

### 3. Structured Logging
Correlate logs with traces:
```ballerina
log:printInfo("Processing customer profile", 
    traceId = observability:getTraceId(),
    customerId = customerId
);
```

### 4. Service Dependency Mapping
Use Jaeger's dependency graph to:
- Visualize service architecture
- Identify critical path dependencies
- Plan capacity and scaling

## Testing Commands for Different Scenarios

```bash
# Generate success traces
curl "http://localhost:8080/banking/customers/1001/profile"

# Generate error traces
curl "http://localhost:8080/banking/customers/9999/profile"

# Load testing
for i in {1..10}; do curl "http://localhost:8080/banking/customers/100$i/profile" & done

# Specific service testing
curl "http://localhost:8081/customer/customers/1001"
curl "http://localhost:8082/analysis/analytics/1001"
```

This setup gives you a complete observability stack for learning distributed tracing, performance analysis, and troubleshooting in a microservices environment.