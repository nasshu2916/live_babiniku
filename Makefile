.PHONY: all
all: test

.PHONY: test
test:
	mix format.all
	mix credo
	mix dialyzer
	mix test
