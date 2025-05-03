TARGETS ?= $(HOME)/stow
STOW = $(shell nu -c "ls $(TARGETS) | where type == dir | get name | path basename | str join ' '")

all: install

.PHONY: install
install:
	@for folder in $(STOW); do echo "Stowing $$folder"; stow -R $$folder 2> /dev/null; done

.PHONY: clean
clean:
	@for folder in $(STOW); do echo "Removing $$folder"; stow -D $$folder 2> /dev/null; done
