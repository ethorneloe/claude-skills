#!/bin/bash
# Beautiful Mermaid Setup Script
# Installs dependencies and creates renderer

set -e

echo "Setting up beautiful-mermaid..."

# Install beautiful-mermaid npm package
echo "Installing beautiful-mermaid package..."
cd /home/claude
npm install beautiful-mermaid --silent 2>/dev/null || npm install beautiful-mermaid 2>&1 | grep -v "npm notice"

# Create the renderer script if it doesn't exist
if [ ! -f /home/claude/beautiful-mermaid-render.mjs ]; then
    echo "Creating renderer script..."
    cat > /home/claude/beautiful-mermaid-render.mjs << 'RENDERER_EOF'
#!/usr/bin/env node
import { renderMermaid, renderMermaidAscii } from 'beautiful-mermaid';

const [diagramCode, theme = 'tokyo-night', format = 'svg'] = process.argv.slice(2);

if (!diagramCode) {
  console.error('Usage: node beautiful-mermaid-render.mjs "<diagram_code>" "<theme>" "<format>"');
  process.exit(1);
}

try {
  if (format === 'ascii') {
    const result = await renderMermaidAscii(diagramCode);
    console.log(result);
  } else {
    const result = await renderMermaid(diagramCode, { theme });
    console.log(result);
  }
} catch (error) {
  console.error('Error rendering diagram:', error.message);
  process.exit(1);
}
RENDERER_EOF
    
    chmod +x /home/claude/beautiful-mermaid-render.mjs
fi

echo "✓ Beautiful-mermaid setup complete!"
echo "Renderer available at: /home/claude/beautiful-mermaid-render.mjs"
