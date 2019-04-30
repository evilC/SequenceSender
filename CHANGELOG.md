# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
- Toggle() method
- WinWaitActive Token
- Unit Tests for parsing function
### Changed 
- Rewrote string parsing code, now much improved
- Tokens now call `OnNext()` themselves, making them extensible
- Tokens now extensible by adding a new class
### Deprecated
### Removed
- Removed Token Delimiter customization
### Fixed

## 0.0.0 - 2019-04-29
### Added
- Initial commit
