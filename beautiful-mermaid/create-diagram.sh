#!/bin/bash
#
# Beautiful Mermaid - Optimized Diagram Creator
# Creates a complete diagram in a single optimized workflow
#
# Usage: bash create-diagram.sh "diagram_code" "title" "output_filename" ["theme"]
#
# Example:
#   bash create-diagram.sh "flowchart TD\n    A --> B" "My Diagram" "my-diagram" "github-dark"

set -e

# Parse arguments
DIAGRAM_CODE="$1"
TITLE="$2"
OUTPUT_NAME="$3"
THEME="${4:-github-dark}"

# Validate required arguments
if [ -z "$DIAGRAM_CODE" ] || [ -z "$TITLE" ] || [ -z "$OUTPUT_NAME" ]; then
    echo "Error: Missing required arguments"
    echo "Usage: bash create-diagram.sh \"diagram_code\" \"title\" \"output_filename\" [\"theme\"]"
    echo ""
    echo "Example:"
    echo "  bash create-diagram.sh \"flowchart TD"
    echo "      A[Start] --> B[End]\" \"My Process\" \"my-process\" \"github-dark\""
    exit 1
fi

# Ensure setup is complete
if [ ! -f /home/claude/beautiful-mermaid-render.mjs ] || [ ! -d /home/claude/node_modules/beautiful-mermaid ]; then
    echo "Running setup..."
    bash /mnt/skills/user/beautiful-mermaid/setup.sh
fi

echo "Creating diagram: $TITLE"

# Step 1: Render the SVG
node /home/claude/beautiful-mermaid-render.mjs "$DIAGRAM_CODE" "$THEME" "svg" > /tmp/diagram-temp.svg

# Step 2: Modify SVG for proper theme colors and bold text
sed -i 's/--bg:#FFFFFF/--bg:#0d1117/g; s/--fg:#27272A/--fg:#e6edf3/g; s/--_inner-stroke:  color-mix(in srgb, var(--fg) 12%, var(--bg));/--_inner-stroke:  #8c959f;/g' /tmp/diagram-temp.svg
sed -i '/<\/style>/i\  text[font-weight="400"] {\n    font-weight: 600;\n  }' /tmp/diagram-temp.svg

# Step 3: Copy template as base
cp /mnt/skills/user/beautiful-mermaid/template.html /tmp/output-temp.html

# Step 4: Replace title and heading
sed -i "s|<title>Diagram Title</title>|<title>${TITLE}</title>|" /tmp/output-temp.html
sed -i "s|<h1>Diagram Title</h1>|<h1>${TITLE}</h1>|" /tmp/output-temp.html

# Step 5: Insert SVG content using awk
awk '
/<!-- INSERT_SVG_HERE -->/ {
    while (getline line < "/tmp/diagram-temp.svg") {
        print "        " line
    }
    # Skip until end of placeholder comment
    while (getline && !/-->/) continue
    next
}
{ print }
' /tmp/output-temp.html > /mnt/user-data/outputs/${OUTPUT_NAME}.html

# Cleanup temp files
rm -f /tmp/diagram-temp.svg /tmp/output-temp.html

echo "✓ Diagram created: /mnt/user-data/outputs/${OUTPUT_NAME}.html"
ls -lh /mnt/user-data/outputs/${OUTPUT_NAME}.html
