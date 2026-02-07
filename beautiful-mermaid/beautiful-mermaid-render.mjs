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
