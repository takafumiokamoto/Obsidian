# makfile

## help command

It is possible to create help command in fllowing code.
found in Pydantic's repository.

```makefile
.PHONY: help  ## Display this message
help:
    @grep -E \
    '^.PHONY: .*?## .*$$' $(MAKEFILE_LIST) | \
    sort | \
    awk 'BEGIN {FS = ".PHONY: |## "}; {printf "\033[36m%-19s\033[0m %s\n", $$2, $$3}'
```
