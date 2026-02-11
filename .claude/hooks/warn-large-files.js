'use strict';

const fs = require('fs');
const path = require('path');
const os = require('os');

let data = '';
process.stdin.on('data', chunk => data += chunk);
process.stdin.on('end', () => {
  let input;
  try {
    input = JSON.parse(data);
  } catch {
    process.stdout.write(data);
    process.exit(0);
  }

  const filePath = input.tool_input?.file_path;
  const sessionId = input.session_id || 'unknown';

  // Pass through input unchanged
  process.stdout.write(data);

  if (!filePath || !fs.existsSync(filePath)) {
    process.exit(0);
  }

  let content;
  try {
    content = fs.readFileSync(filePath, 'utf8');
  } catch {
    process.exit(0);
  }

  const lineCount = content.replace(/\n$/, '').split('\n').length;

  if (lineCount <= 500) {
    process.exit(0);
  }

  // Check if we already warned about this file this session
  const safeSessionId = sessionId.replace(/[^a-zA-Z0-9_-]/g, '_');
  const warnFile = path.join(os.tmpdir(), `.claude-file-size-warned-${safeSessionId}`);
  let warned = [];
  try {
    warned = JSON.parse(fs.readFileSync(warnFile, 'utf8'));
  } catch {
    // File doesn't exist or is invalid - start fresh
  }

  if (warned.includes(filePath)) {
    process.exit(0);
  }

  // Warn and record
  console.error(`[Hook] WARNING: ${filePath} is ${lineCount} lines (guideline: 200-400 typical, 800 max). Consider extracting hooks/components.`);

  warned.push(filePath);
  try {
    fs.writeFileSync(warnFile, JSON.stringify(warned));
  } catch {
    // Dedup cache write failed; next invocation will warn again. Acceptable.
  }
});
