# Banking Microservices - Complete Observability Demo

This project demonstrates comprehensive observability in a Ballerina microservices architecture with distributed tracing, metrics, structured logging, and integrated dashboards.

## 🚀 Quick Start

```bash
# Start the complete observability stack
cd observability
docker-compose up -d

# Test all components
../scripts/test-observability-stack.sh

# Generate test traffic
../scripts/generate-test-traffic.sh
```

**Access Points:**
- 🔍 **Jaeger Tracing**: http://localhost:16686
- 📊 **Grafana Dashboards**: http://localhost:3000 (admin/admin) - **All dashboards auto-imported!**
- 📈 **Prometheus Metrics**: http://localhost:9090
- 📝 **Loki Logs**: Integrated with Grafana
- 🏦 **Banking API**: http://localhost:8080/banking/health

## �️ Testing Scripts

### Core Scripts
```
├── scripts/
│   ├── test-observability-stack.sh   # 🔬 Complete observability stack test
│   ├── generate-test-traffic.sh      # 🚀 Generate test traffic (success/errors/mixed)
│   └── debug-mysql-database.sh       # 🗄️  MySQL debugging utility
```

### Usage Examples
```bash
# Test entire observability stack
cd observability && ../scripts/test-observability-stack.sh

# Generate mixed traffic (recommended for demos)  
../scripts/generate-test-traffic.sh mixed

# Generate only successful requests
../scripts/generate-test-traffic.sh success

# Generate only error requests  
../scripts/generate-test-traffic.sh errors

# Debug MySQL database issues
../scripts/debug-mysql-database.sh
```

## 📁 Project Structure

### Core Application Files
```
├── *.bal                     # Ballerina microservice files
├── types.bal                 # Shared type definitions  
├── Config*.toml              # Ballerina configuration files
├── Dockerfile               # Container build configuration
```

### Documentation
```
├── docs/
│   └── JAEGER_GUIDE.md     # Complete Jaeger tracing guide
├── progress.md             # Current project status
└── README.md              # This file
```

### Observability Stack
```
├── observability/
│   ├── docker-compose.yml          # Container orchestration
│   ├── prometheus/
│   │   └── prometheus.yml          # Metrics collection config
│   ├── grafana/
│   │   ├── dashboards/             # Auto-imported dashboards
│   │   │   ├── ballerina-metrics.json
│   │   │   ├── ballerina-logs.json
│   │   │   └── ballerina-tracing.json
│   │   └── provisioning/           # Auto-configuration
│   ├── loki/
│   │   └── loki.yml                # Log aggregation config
│   ├── fluent-bit/
│   │   └── fluent-bit.conf         # Log collection config
│   └── jaeger/                     # Distributed tracing config
```

## Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Client        │    │  Banking        │    │  Customer       │
│                 │───▶│  Service        │───▶│  Service        │
│                 │    │  (Port 8080)    │    │  (Port 8081)    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │                        │
                                │                        │
                                ▼                        │
                       ┌─────────────────┐               │
                       │  Analytics      │◀──────────────┘
                       │  Service        │
                       │  (Port 8082)    │
                       └─────────────────┘
                                │
                                ▼
                       ┌─────────────────┐
                       │  MySQL          │
                       │  Database       │
                       └─────────────────┘
```

## Services

### 1. Banking Service (Port 8080)
- **Purpose**: Main service that orchestrates calls to other services
- **Features**:
  - Customer account management
  - Transaction history
  - Complete customer profile aggregation
  - Health checks for all downstream services
- **Database**: Direct MySQL connection
- **Tracing**: Full distributed tracing with Jaeger

### 2. Customer Service (Port 8081)
- **Purpose**: Manages customer personal information
- **Features**:
  - Customer details from CSV files
  - Simulated network delays (100-500ms)
  - Random failure scenarios (10% chance)
  - CSV to JSON transformation
- **Data Source**: CSV files in `/data` directory
- **Failure Simulation**: Network timeouts and processing errors

### 3. Analytics Service (Port 8082)
- **Purpose**: Data aggregation and analytics processing
- **Features**:
  - Customer transaction analytics
  - Global analytics summary
  - CSV data transformation
  - Complex aggregations and calculations
- **Data Source**: Analytics CSV files
- **Processing**: Heavy computational workloads (200-800ms delays)

## 🔭 Comprehensive Observability Stack

### 🕵️ Distributed Tracing (Jaeger)
- **URL**: http://localhost:16686
- **Purpose**: Track requests across all microservices
- **Features**:
  - End-to-end request tracing with correlation IDs
  - Service dependency mapping and visualization
  - Latency analysis and bottleneck identification
  - Error propagation tracking across services
  - Time-synchronized links from Grafana dashboards

### 📊 Metrics & Dashboards (Prometheus + Grafana)
- **Prometheus**: http://localhost:9090 (metrics collection)
- **Grafana**: http://localhost:3000 (admin/admin) (visualization)
- **Auto-Imported Dashboards**:
  - **Ballerina Metrics**: Complete performance overview with error filtering
  - **Application Logs**: Structured logging with trace correlation
  - **Jaeger Tracing**: Distributed tracing dashboard integration
- **Metrics Collected**:
  - HTTP request rates, latencies, and status codes
  - Database connection metrics
  - Custom business metrics
  - Error rates (excluding health checks for accurate percentages)
  - Cross-service communication patterns

### 📝 Structured Logging (Loki + Fluent Bit)
- **Loki**: Log aggregation (integrated with Grafana)
- **Fluent Bit**: Log collection and parsing
- **Features**:
  - JSON structured logging for easy parsing
  - TraceID correlation linking logs to Jaeger traces
  - Service-specific log levels and filtering
  - Real-time error log monitoring
  - Clickable trace correlation from logs

### 🔗 Integrated Features
- **TraceID Linking**: Click traceIds in logs to view traces in Jaeger UI
- **Cross-Dashboard Navigation**: Jump between metrics, logs, and tracing
- **Time Synchronization**: Coordinated time ranges across all dashboards
- **Error Correlation**: Track errors from metrics → logs → traces
- **Health Check Filtering**: Business logic metrics exclude operational endpoints

## 🚀 Quick Start Guide

### 1. Start the Complete Stack
```bash
cd observability
docker-compose up -d
```

This automatically:
- Starts MySQL, Jaeger, Prometheus, Grafana, Loki, and Fluent Bit
- Builds and starts all 3 Ballerina microservices
- Auto-imports all Grafana dashboards with proper data source configuration
- Configures TraceID correlation between logs and traces

### 2. Test the Observability Stack
```bash
# Test all components and generate sample traces
../scripts/test-observability-stack.sh
```

### 3. Generate Demo Traffic
```bash
# Generate mixed traffic for realistic demo data
../scripts/generate-test-traffic.sh mixed
```

### 3. Stop All Services
```bash
cd observability
docker-compose down

# Optional: Remove data volumes
docker-compose down -v
```

## Troubleshooting Microservices with Observability

### 1. Identifying Performance Bottlenecks

#### Using Jaeger Traces
1. Access Jaeger UI: http://localhost:16686
2. Search for traces with high latency
3. Look for the **critical path** - longest span in the trace
4. Identify which service is the bottleneck:
   - **Database queries**: Look for MySQL spans
   - **Service calls**: Check HTTP client spans
   - **Processing time**: Compare span durations

**Example**: If `/customers/{id}/profile` takes 2 seconds:
- Check Banking Service span (should be ~50ms for coordination)
- Check Customer Service span (100-500ms expected)
- Check Analytics Service span (200-800ms expected)
- Check Database spans (should be <50ms per query)

#### Using Prometheus Metrics
1. Access Prometheus: http://localhost:9090
2. Key queries for bottleneck identification:
   ```promql
   # Request latency by service
   http_request_duration_seconds{quantile="0.95"}
   
   # Request rate by endpoint
   rate(http_requests_total[5m])
   
   # Error rate by service
   rate(http_requests_total{status=~"5.."}[5m])
   ```

### 2. Troubleshooting Errors

#### Using Distributed Tracing
1. **Error Propagation**: Follow traces to see how errors flow between services
2. **Root Cause**: Identify the originating service for an error
3. **Impact Analysis**: See which downstream services are affected

**Common Error Scenarios**:
- **Network Timeouts**: Look for spans with `error=true` and timeout messages
- **Database Failures**: Check MySQL connection spans
- **Service Unavailability**: Missing spans from unreachable services

#### Using Structured Logs
1. **Correlation**: Use request IDs to correlate logs across services
2. **Error Context**: JSON logs provide detailed error information
3. **Debugging**: Filter by log level (ERROR, WARN, INFO, DEBUG)

### 3. Monitoring Service Health

#### Health Check Endpoints
- Banking Service: `GET /health`
- Customer Service: `GET /health`
- Analytics Service: `GET /health`

#### Red Metrics (Rate, Errors, Duration)
1. **Rate**: Number of requests per second
2. **Errors**: Percentage of failed requests
3. **Duration**: Response time percentiles

#### Database Monitoring
- Connection pool utilization
- Query execution times
- Connection failures

## Error Scenarios for Testing

### 1. Network Failures
```bash
# Customer Service has 10% random failure rate
curl http://localhost:8081/customers/1001

# Simulate specific failure
curl -X POST http://localhost:8081/simulate/failure
```

### 2. Database Issues
```bash
# Stop MySQL container
docker stop mysql_banking

# Try to access data-dependent endpoints
curl http://localhost:8080/customers/1001/accounts
```

### 3. Service Unavailability
```bash
# Kill a service process
kill <CUSTOMER_SERVICE_PID>

# Test downstream impact
curl http://localhost:8080/customers/1001/profile
```

### 4. File Processing Errors
```bash
# Corrupt CSV files
mv data/customers.csv data/customers.csv.backup
echo "invalid,csv,data" > data/customers.csv

# Test customer service
curl http://localhost:8081/customers/1001
```

## Key Observability Patterns

### 1. Correlation IDs
- Every request gets a unique correlation ID
- ID is passed between all services
- Enables log correlation across the entire request flow

### 2. Circuit Breaker Pattern
- Services fail fast when downstream dependencies are unavailable
- Prevents cascade failures
- Returns cached/default responses when possible

### 3. Structured Logging
```json
{
  "timestamp": "2024-09-24T10:30:45Z",
  "level": "INFO",
  "service": "banking-service",
  "correlationId": "req-123-456",
  "operation": "get-customer-profile",
  "customerId": 1001,
  "processingTime": 1.25,
  "message": "Customer profile retrieved successfully"
}
```

### 4. Business Metrics
- Customer profile retrieval count
- Transaction processing rates
- Service availability percentages
- Data processing volumes

## Common Issues and Solutions

### Issue 1: High Latency
**Symptoms**: Slow response times, timeout errors
**Investigation**:
1. Check Jaeger for bottleneck services
2. Look at database query performance
3. Check for resource contention

### Issue 2: Service Errors
**Symptoms**: HTTP 5xx errors, failed requests
**Investigation**:
1. Check service logs for error details
2. Verify service health endpoints
3. Check dependency availability

### Issue 3: Data Inconsistency
**Symptoms**: Mismatched data between services
**Investigation**:
1. Check data transformation logs
2. Verify CSV file integrity
3. Compare database vs. file data

## Useful Commands

```bash
# View all service logs
docker compose -f observability/docker-compose.yml logs -f

# Check Ballerina service processes
ps aux | grep ballerina

# Monitor resource usage
docker stats

# Check database connectivity
mysql -h localhost -u root -ppassword123 banking_demo

# View service metrics
curl http://localhost:8080/actuator/prometheus
```

## Next Steps

1. **Custom Dashboards**: Create Grafana dashboards for business metrics
2. **Alerting**: Set up alerts for error rates and latency thresholds  
3. **Log Aggregation**: Add ELK stack for centralized log management
4. **Testing**: Add automated tests for error scenarios
5. **Documentation**: Create runbooks for common issues