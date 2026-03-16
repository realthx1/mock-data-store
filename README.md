# mock-data-store
**Complete mock implementation of DataStoreService**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)](LICENSE)
[![pesde](https://img.shields.io/github/v/tag/realthx1/mock_data_store?&style=for-the-badge&label=pesde)](https://pesde.dev/packages/realthx1/mock_data_store)

## Installation
Using [**pesde**](https://pesde.dev/):
```bash
pesde add realthx1/mock_data_store -t roblox
```

## Usage
TODO

## Documentation
TODO

Refer to [the original documentation](https://create.roblox.com/docs/reference/engine/classes/DataStoreService) for methods and classes related to a created mock DataStoreService.

## Deviations
* TODO
* Currently, almost no methods throw errors with original error messages, this will be fixed in the future.
* Throttling and request limits are currently not simulated.
* Yielding is not checked.
* Some data may not be copied, but used as passed instead.
* There are no GetRequestBudgetForRequestType and SetRateLimitForRequestType methods.
* Deprecated and unlisted methods/properties are not implemented.
