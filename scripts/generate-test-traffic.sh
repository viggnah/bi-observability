#!/bin/bash

echo "🚀 === Generate Test Traffic for Observability Testing ==="
echo ""

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

BANKING_URL="http://localhost:8080/banking"

echo -e "${BLUE}This script generates various types of traffic for testing:${NC}"
echo "• Successful requests (for normal metrics)"  
echo "• Error requests (for error tracking)"
echo "• Distributed traces (across all services)"
echo ""

# Function to generate successful traffic
generate_success_traffic() {
    echo -e "${YELLOW}Generating successful requests...${NC}"
    
    local customers=(1001 1002 1003 1004 1005)
    
    for customer in "${customers[@]}"; do
        echo "  📊 Customer $customer profile..."
        curl -s "$BANKING_URL/customers/$customer/profile" > /dev/null
        sleep 0.5
        
        echo "  💰 Customer $customer accounts..."
        curl -s "$BANKING_URL/customers/$customer/accounts" > /dev/null
        sleep 0.5
        
        echo "  💳 Customer $customer transactions..."
        curl -s "$BANKING_URL/customers/$customer/transactions" > /dev/null
        sleep 0.5
    done
}

# Function to generate error traffic
generate_error_traffic() {
    echo -e "${YELLOW}Generating error requests...${NC}"
    
    # Bad customer IDs
    local bad_customers=(9999 8888 7777)
    for customer in "${bad_customers[@]}"; do
        echo "  ❌ Invalid customer $customer..."
        curl -s "$BANKING_URL/customers/$customer/profile" > /dev/null
        sleep 0.3
    done
    
    # Invalid endpoints
    echo "  ❌ Invalid endpoints..."
    curl -s "$BANKING_URL/invalid-endpoint-1" > /dev/null
    curl -s "$BANKING_URL/nonexistent/path" > /dev/null
    curl -s "$BANKING_URL/customers/abc/profile" > /dev/null
}

# Main execution
case "${1:-mixed}" in
    "success")
        generate_success_traffic
        echo -e "${GREEN}✅ Generated successful traffic only${NC}"
        ;;
    "errors")
        generate_error_traffic  
        echo -e "${GREEN}✅ Generated error traffic only${NC}"
        ;;
    "mixed"|"")
        echo "Generating mixed traffic (success + errors)..."
        echo ""
        generate_success_traffic
        echo ""
        generate_error_traffic
        echo ""
        echo -e "${GREEN}✅ Generated mixed traffic (should see ~20% error rate)${NC}"
        ;;
    *)
        echo "Usage: $0 [success|errors|mixed]"
        echo ""
        echo "Options:"
        echo "  success  - Generate only successful requests"
        echo "  errors   - Generate only error requests"
        echo "  mixed    - Generate both (default)"
        exit 1
        ;;
esac

echo ""
echo "📊 Check the results in:"
echo "  • Jaeger UI:   http://localhost:16686"
echo "  • Grafana:     http://localhost:3000"
echo "  • Prometheus:  http://localhost:9090"