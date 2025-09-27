#!/bin/bash

echo "🔭 === Ballerina Banking - Integrated Observability Stack Test ==="
echo "Testing: Jaeger Tracing + Prometheus Metrics + Loki Logging + Grafana Dashboards"
echo ""

# Check if we're in the right directory
if [[ ! -f "docker-compose.yml" ]]; then
    echo "❌ Please run this script from the observability directory"
    echo "Usage: cd observability && ../scripts/test-observability-stack.sh"
    exit 1
fi

# Color codes for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# URLs for the banking microservices
BANKING_URL="http://localhost:8080/banking"
CUSTOMER_URL="http://localhost:8081/customer"
ANALYSIS_URL="http://localhost:8082/analysis"

echo "🌐 Service URLs:"
echo "   Banking: $BANKING_URL"
echo "   Customer: $CUSTOMER_URL"
echo "   Analysis: $ANALYSIS_URL"
echo ""

echo "📊 Observability URLs:"
echo "   Jaeger UI:   http://localhost:16686"
echo "   Grafana:     http://localhost:3000 (admin/admin)"
echo "   Prometheus:  http://localhost:9090"
echo ""

# Function to check container health
check_container() {
    local container_name=$1
    if docker ps --format 'table {{.Names}}' | grep -q "^${container_name}$"; then
        echo -e "   ✅ ${GREEN}${container_name}${NC}"
        return 0
    else
        echo -e "   ❌ ${RED}${container_name}${NC}"
        return 1
    fi
}

# Function to make HTTP request and capture response
make_request() {
    local url=$1
    local description=$2
    local expected_status=$3
    
    echo -e "   📡 ${BLUE}$description${NC}"
    echo "      URL: $url"
    
    # Make request and capture both status and response
    local response=$(curl -s -w "HTTPSTATUS:%{http_code}" "$url" 2>/dev/null)
    local http_body=$(echo "$response" | sed -E 's/HTTPSTATUS:[0-9]{3}$//')
    local http_status=$(echo "$response" | tr -d '\n' | sed -E 's/.*HTTPSTATUS:([0-9]{3})$/\1/')
    
    if [[ "$http_status" == "$expected_status" ]]; then
        echo -e "      ✅ ${GREEN}Status: $http_status${NC}"
        if [[ ${#http_body} -gt 100 ]]; then
            echo "      Response: $(echo "$http_body" | head -c 100)..."
        else
            echo "      Response: $http_body"
        fi
        return 0
    else
        echo -e "      ❌ ${RED}Status: $http_status (expected $expected_status)${NC}"
        echo "      Response: $http_body"
        return 1
    fi
}

# 1. SERVICE HEALTH CHECKS
echo -e "${YELLOW}1. CONTAINER HEALTH CHECKS${NC}"
echo "============================"

containers=("mysql_banking" "jaeger" "prometheus" "grafana" "loki" "fluent-bit" "bi-services")
failed_containers=0

for container in "${containers[@]}"; do
    if ! check_container "$container"; then
        ((failed_containers++))
    fi
done

if [[ $failed_containers -gt 0 ]]; then
    echo ""
    echo -e "❌ ${RED}$failed_containers container(s) not running. Start with:${NC}"
    echo "   docker-compose up -d"
    exit 1
fi

echo ""

# 2. OBSERVABILITY ENDPOINTS TEST
echo -e "${YELLOW}2. OBSERVABILITY ENDPOINTS TEST${NC}"
echo "================================"

# Test Prometheus
echo -e "🔥 ${BLUE}Testing Prometheus${NC}"
if make_request "http://localhost:9090/-/healthy" "Prometheus health check" "200"; then
    echo "   📊 Metrics endpoint: http://localhost:9090/metrics"
else
    echo "   ❌ Prometheus not accessible"
fi

# Test Jaeger  
echo ""
echo -e "🕵️ ${BLUE}Testing Jaeger${NC}"
if make_request "http://localhost:16686/" "Jaeger UI" "200"; then
    echo "   🔍 Traces can be viewed at: http://localhost:16686"
else
    echo "   ❌ Jaeger not accessible"
fi

# Test Grafana
echo ""
echo -e "📈 ${BLUE}Testing Grafana${NC}"
if make_request "http://localhost:3000/api/health" "Grafana health" "200"; then
    echo "   📊 Dashboards: http://localhost:3000 (admin/admin)"
else
    echo "   ❌ Grafana not accessible"
fi

echo ""

# 3. BUSINESS LOGIC TESTS (with tracing)
echo -e "${YELLOW}3. BUSINESS LOGIC & DISTRIBUTED TRACING TEST${NC}"
echo "============================================="

echo -e "🏦 ${BLUE}Testing Banking Service (creates traces across all services)${NC}"

# Test successful customer profile retrieval (triggers Banking -> Customer -> Analysis)
make_request "$BANKING_URL/customers/1001/profile" "Get customer 1001 profile (distributed trace)" "200"
sleep 1

make_request "$BANKING_URL/customers/1002/accounts" "Get customer 1002 accounts" "200"
sleep 1

make_request "$BANKING_URL/customers/1003/transactions" "Get customer 1003 transactions" "200"
sleep 1

# Test error scenarios for error metrics
echo ""
echo -e "⚠️ ${YELLOW}Testing Error Scenarios (for error tracking)${NC}"
make_request "$BANKING_URL/customers/9999/profile" "Non-existent customer (400 error)" "400"
make_request "$BANKING_URL/invalid-endpoint" "Invalid endpoint (404 error)" "404"

echo ""

# 4. METRICS VALIDATION
echo -e "${YELLOW}4. METRICS VALIDATION${NC}"
echo "====================="

echo "📊 Checking if metrics are being collected..."

# Check for Ballerina metrics
if curl -s "http://localhost:9090/api/v1/query?query=requests_total_value" | grep -q '"result":\['; then
    echo -e "   ✅ ${GREEN}Request metrics found${NC}"
else
    echo -e "   ❌ ${RED}No request metrics found${NC}"
fi

if curl -s "http://localhost:9090/api/v1/query?query=response_errors_total_value" | grep -q '"result":\['; then
    echo -e "   ✅ ${GREEN}Error metrics found${NC}"
else
    echo -e "   ❌ ${RED}No error metrics found${NC}"
fi

echo ""

# 5. FINAL SUMMARY
echo -e "${YELLOW}5. OBSERVABILITY STACK SUMMARY${NC}"  
echo "==============================="
echo ""
echo "🔗 Quick Links:"
echo "   • Jaeger Traces:       http://localhost:16686"
echo "   • Grafana Dashboards:  http://localhost:3000"
echo "     - Metrics Dashboard: http://localhost:3000/d/ballerina-metrics"  
echo "     - Logs Dashboard:    http://localhost:3000/d/ballerina-logs"
echo "     - Jaeger Dashboard:  http://localhost:3000/d/jaeger-tracing"
echo "   • Prometheus Metrics:  http://localhost:9090"
echo ""
echo "📋 What to check:"
echo "   1. View distributed traces in Jaeger UI"
echo "   2. Check metrics in Grafana dashboards"
echo "   3. Verify error rates and performance"
echo "   4. Test TraceID linking from logs to Jaeger"
echo ""
echo -e "✅ ${GREEN}Observability stack test completed!${NC}"
echo ""
echo "💡 Tips:"
echo "   - Generate more traffic to see better metrics"
echo "   - Check 'How bad is it?' panel for error rates"
echo "   - Use TraceID links in logs to jump to Jaeger traces"