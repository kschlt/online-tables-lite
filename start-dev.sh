#!/bin/bash

echo "🚀 Starting Online Tables Lite Development Environment"
echo ""

# Check if we're in the right directory
if [ ! -f "apps/web/package.json" ] || [ ! -f "apps/api/main.py" ]; then
    echo "❌ Error: Please run this script from the project root directory"
    exit 1
fi

# Start backend in background
echo "🔧 Starting backend server..."
cd apps/api
source venv/bin/activate
python3 main.py &
BACKEND_PID=$!
cd ..

# Start frontend in background
echo "📱 Starting frontend server..."
cd apps/web
npm run dev &
FRONTEND_PID=$!
cd ..

echo ""
echo "✅ Both servers are starting up!"
echo "📱 Frontend: http://localhost:3000"
echo "🔧 Backend: http://localhost:8000"
echo ""
echo "Press Ctrl+C to stop both servers"

# Wait for interrupt
trap "echo ''; echo '🛑 Stopping servers...'; kill $BACKEND_PID $FRONTEND_PID; exit 0" INT
wait
