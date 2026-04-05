#!/bin/bash
set -e
cd "$(dirname "$0")"
REPORT="result.txt"
echo "=== Sparse File Tool — Test Report ===" > "$REPORT"
echo "Date: $(date)" >> "$REPORT"
echo "Environment: WSL2 Ubuntu $(lsb_release -rs)" >> "$REPORT"
echo "" >> "$REPORT"

echo "Building..." | tee -a "$REPORT"
cd src && make clean >/dev/null 2>&1 || true && make && cd ..
echo "Build successful" | tee -a "$REPORT"

echo "Creating test file A..." | tee -a "$REPORT"
bash scripts/create_test_file.sh | tee -a "$REPORT"

echo "Copying A → B (block=4096)..." | tee -a "$REPORT"
./src/sparse_tool fileA fileB
echo "Created B" | tee -a "$REPORT"

echo "Compressing..." | tee -a "$REPORT"
gzip -k fileA && gzip -k fileB

echo "Decompressing B.gz → C..." | tee -a "$REPORT"
gzip -cd fileB.gz | ./src/sparse_tool fileC
echo "Created C" | tee -a "$REPORT"

echo "Copying A → D (block=100)..." | tee -a "$REPORT"
./src/sparse_tool -b 100 fileA fileD
echo "Created D" | tee -a "$REPORT"

echo "" >> "$REPORT"
echo "File sizes:" | tee -a "$REPORT"
for f in fileA fileA.gz fileB fileB.gz fileC fileD; do
  [ -f "$f" ] || continue
  logical=$(stat -c "%s" "$f")
  blocks=$(stat -c "%b" "$f")
  blksize=$(stat -c "%B" "$f")
  actual=$((blocks * blksize))
  echo "$f: logical=$logical bytes, disk=$actual bytes" | tee -a "$REPORT"
  [ "$actual" -lt "$logical" ] && [ "$logical" -gt 0 ] && echo "SPARSE" | tee -a "$REPORT"
done
echo "" | tee -a "$REPORT"
echo "All tests completed." | tee -a "$REPORT"
cat "$REPORT"
