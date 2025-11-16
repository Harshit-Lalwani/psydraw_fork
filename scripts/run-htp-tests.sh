#!/bin/bash
# Script to run HTP analysis tests inside Docker container

echo "🧪 Running HTP analysis tests inside Docker container..."
echo ""

# Create report directory
mkdir -p /app/report

# Run tests for each example (only those that exist)
examples=("example1.jpg" "example2.jpg" "example3.jpg")
success_count=0
fail_count=0

for i in "${!examples[@]}"; do
    example="${examples[$i]}"
    num=$((i + 1))
    echo "📝 Testing with ${example}..."
    
    if python /app/run.py \
        --image_file "/app/example/${example}" \
        --save_path "/app/report/test_example${num}_result.json" \
        --language en; then
        echo "✅ Example ${num} passed"
        success_count=$((success_count + 1))
    else
        echo "❌ Example ${num} failed"
        fail_count=$((fail_count + 1))
    fi
    echo ""
done

echo "================================"
echo "📊 Test Results Summary:"
echo "   ✅ Passed: ${success_count}"
echo "   ❌ Failed: ${fail_count}"
echo "   📁 Results saved to: report/"
echo "================================"
echo ""

if [ $fail_count -eq 0 ]; then
    echo "🎉 All HTP tests passed!"
    exit 0
else
    echo "⚠️  Some tests failed. Check the output above."
    exit 1
fi
