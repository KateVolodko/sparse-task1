CC = gcc
CFLAGS = -Wall -Wextra -O2 -std=c11
TARGET = sparse_tool

all: $(TARGET)

$(TARGET): main.c
	$(CC) $(CFLAGS) -o $@ $<

clean:
	rm -f $(TARGET)

.PHONY: all clean
