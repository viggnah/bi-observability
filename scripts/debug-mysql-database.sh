#!/bin/bash

echo "🗄️ === MySQL Banking Database - Debug & Troubleshooting Utility ==="
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 1. Container Status Check
echo -e "${YELLOW}1. MYSQL CONTAINER STATUS${NC}"
echo "=========================="

if ! docker ps | grep -q mysql_banking; then
    echo -e "❌ ${RED}MySQL container is not running${NC}"
    echo "Start services with: cd observability && docker-compose up -d"
    exit 1
fi

echo -e "✅ ${GREEN}MySQL container is running${NC}"
echo ""
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "(NAMES|mysql_banking)"

echo ""

# 2. Container Logs
echo -e "${YELLOW}2. RECENT MYSQL LOGS${NC}"
echo "===================="
docker logs mysql_banking --tail 10

echo ""

# 3. Connection Test
echo -e "${YELLOW}3. DATABASE CONNECTION TEST${NC}"
echo "==========================="

echo "Testing MySQL connection..."
if docker exec mysql_banking mysql -uroot -prootpassword -e "SELECT 'Connection successful' as status;" 2>/dev/null; then
    echo -e "✅ ${GREEN}Database connection successful${NC}"
else
    echo -e "❌ ${RED}Database connection failed${NC}"
    echo "Check container logs above for errors"
    exit 1
fi

echo ""

# 4. Database Structure
echo -e "${YELLOW}4. BANKING DATABASE STRUCTURE${NC}"
echo "=============================="

echo "Databases:"
docker exec mysql_banking mysql -uroot -prootpassword -e "SHOW DATABASES;" 2>/dev/null

echo ""
echo "Banking database tables:"
docker exec mysql_banking mysql -uroot -prootpassword -D banking -e "SHOW TABLES;" 2>/dev/null

echo ""

# 5. Sample Data Check  
echo -e "${YELLOW}5. SAMPLE DATA VERIFICATION${NC}"
echo "==========================="

echo "Customer count:"
docker exec mysql_banking mysql -uroot -prootpassword -D banking -e "SELECT COUNT(*) as customer_count FROM customers;" 2>/dev/null

echo ""
echo "Account count:" 
docker exec mysql_banking mysql -uroot -prootpassword -D banking -e "SELECT COUNT(*) as account_count FROM accounts;" 2>/dev/null

echo ""
echo "Transaction count:"
docker exec mysql_banking mysql -uroot -prootpassword -D banking -e "SELECT COUNT(*) as transaction_count FROM transactions;" 2>/dev/null

echo ""
echo "Sample customers (first 3):"
docker exec mysql_banking mysql -uroot -prootpassword -D banking -e "SELECT customer_id, first_name, last_name, email FROM customers LIMIT 3;" 2>/dev/null

echo ""

# 6. Troubleshooting Commands
echo -e "${YELLOW}6. TROUBLESHOOTING COMMANDS${NC}"
echo "==========================="
echo ""
echo "Useful commands for debugging:"
echo ""
echo "• View all logs:"
echo "  docker logs mysql_banking"
echo ""  
echo "• Connect to MySQL directly:"
echo "  docker exec -it mysql_banking mysql -uroot -prootpassword -D banking"
echo ""
echo "• Restart MySQL container:"
echo "  docker-compose restart mysql_banking"
echo ""
echo "• Check MySQL process list:"
echo "  docker exec mysql_banking mysql -uroot -prootpassword -e 'SHOW PROCESSLIST;'"
echo ""
echo "• Check MySQL variables:"
echo "  docker exec mysql_banking mysql -uroot -prootpassword -e 'SHOW VARIABLES LIKE \"%timeout%\";'"
echo ""
echo -e "✅ ${GREEN}MySQL debug information completed!${NC}"