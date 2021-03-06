# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
### Changed 
### Deprecated
### Removed
### Fixed

## 0.0.1 - 2020-08-12
### Added
- Toggle() method
- SetState() method
- WinWaitActive, WinWaitNotActive, WinActivate, ControlSend, SetKeyDelay Tokens
- Unit Tests for parsing function and errors
- Sample Custom Token class
### Changed 
- Rewrote string parsing code, now much improved
- Tokens now call `OnNext()` themselves, making them extensible
- Tokens now extensible by adding a new class  
- Added AddTokenClass endpoint
### Deprecated
### Removed
- Removed Token Delimiter customization
### Fixed
- Fix Braces in Braces (`{{}` and `{}}`)
- Issue #5 fixed - spaces between characters no longer deleted

## 0.0.0 - 2019-04-29
### Added
- Initial commit
