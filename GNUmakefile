TESTS = $(wildcard tests/*.lean)

.PHONY: all build test lint

all: build test

build:
	lake build

test: $(addsuffix .run, $(TESTS))

tests/%.run: build
	lake env lean tests/$*

lint: build
	./build/bin/runLinter
