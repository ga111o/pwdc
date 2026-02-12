# Makefile for pwdc

PREFIX ?= $(HOME)/.local
BINDIR = $(PREFIX)/bin

.PHONY: all install uninstall clean help

all: help

install:
	@echo "Running installation script..."
	@chmod +x install.sh
	@chmod +x pwdc
	@./install.sh

uninstall:
	@echo "Uninstalling pwdc..."
	@rm -f $(BINDIR)/pwdc
	@echo "pwdc has been uninstalled from $(BINDIR)"

clean:
	@echo "Nothing to clean (no build artifacts)"

test:
	@echo "Testing pwdc..."
	@chmod +x pwdc
	@./pwdc
	@echo ""
	@echo "If you see the copied path above, the test was successful!"

help:
	@echo "pwdc - Copy current directory to clipboard"
	@echo ""
	@echo "Available targets:"
	@echo "  make install   - Install pwdc (interactive)"
	@echo "  make uninstall - Remove pwdc"
	@echo "  make test      - Test pwdc without installing"
	@echo "  make help      - Show this help message"
	@echo ""
	@echo "Usage after installation:"
	@echo "  pwdc           - Copy full current directory path to clipboard"
	@echo "  pwdc .         - Copy only current directory name to clipboard"
	@echo "  pwdc ./path    - Copy current directory + path to clipboard"
