CC ?= gcc
CFLAGS = -Wall -Wextra -O2 -std=c99
PREFIX ?= /usr/local

.PHONY: all clean install

all: nanos-sysinfo

nanos-sysinfo: nanos-sysinfo.c
	$(CC) $(CFLAGS) -o $@ $<

install: nanos-sysinfo
	install -Dm755 nanos-sysinfo $(DESTDIR)$(PREFIX)/bin/nanos-sysinfo

clean:
	rm -f nanos-sysinfo
