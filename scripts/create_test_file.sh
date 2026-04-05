#!/bin/bash
SIZE=$((4*1024*1024 + 1))
echo "Creating fileA ($SIZE bytes)..."
truncate -s $SIZE fileA
printf '\x01' | dd of=fileA bs=1 seek=0 conv=notrunc 2>/dev/null
printf '\x01' | dd of=fileA bs=1 seek=10000 conv=notrunc 2>/dev/null
printf '\x01' | dd of=fileA bs=1 seek=$((SIZE-1)) conv=notrunc 2>/dev/null
echo "fileA created"
