## [0.2.0] - 2025-10-28

### Added
- Structured error classes with contextual information (`status`, `code`, `details`)
- Extensive WebMock-backed RSpec coverage for every Admin API endpoint and error path

### Changed
- Improved error handling to map Node-RED response codes (400/401/404/409/5xx) to dedicated exceptions
- Enhanced JSON parsing safeguards on responses and errors for clearer diagnostics
- Updated README with advanced error-handling guidance

## [0.1.0] - 2025-10-28

- Initial release
- Full implementation of Node-RED Admin HTTP API wrapper
- Authentication endpoints (login, token exchange, revoke)
- Settings and diagnostics endpoints
- Complete flow management (CRUD operations, state management)
- Complete node management (install, update, delete modules and sets)
- Custom error classes for better error handling
- Comprehensive documentation and examples
