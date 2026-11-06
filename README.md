[![Swift](https://github.com/georgmay/state-machine/workflows/Swift/badge.svg?branch=master)](https://github.com/georgmay/state-machine/actions)

# State Machine

A small, classic [finite state machine](https://en.wikipedia.org/wiki/Finite-state_machine) for Swift.

You describe your states, events and the transitions between them. The machine keeps track of the current state and moves it when an event arrives.

- Generic over any `Hashable` state and event types, usually plain enums
- Transition table defined with a compact operator syntax
- `onEnter` / `onExit` callbacks
- Events with no matching transition are ignored
- Conflicting transitions (same event from the same state) are rejected
- No dependencies

## Requirements

- Swift 6.0+ toolchain (Xcode 16 or newer)
- macOS 10.13+, iOS 11+, tvOS 11+

## Installation

Add the package to your `Package.swift`:

```swift
dependencies: [
	.package(url: "https://github.com/georgmay/state-machine.git", branch: "master")
],
targets: [
	.target(name: "YourTarget", dependencies: [
		.product(name: "StateMachine", package: "state-machine")
	])
]
```

Or in Xcode: **File → Add Package Dependencies…** and paste the repository URL.

## Usage

### Define states and events

```swift
import StateMachine

enum Event {
	case coin
	case push
}

enum State {
	case locked
	case unlocked
}
```

### Build the machine

Create the machine with its starting state, then register transitions as `(event, source, destination)`:

```swift
let turnstile = FiniteStateMachine<State, Event>(default: .locked)

turnstile <<~ (.coin, .locked, .unlocked)
turnstile <<~ (.coin, .unlocked, .unlocked)
turnstile <<~ (.push, .unlocked, .locked)
turnstile <<~ (.push, .locked, .locked)
```

### Send events

```swift
turnstile ~>> .coin
turnstile.current // .unlocked

turnstile ~>> .push
turnstile.current // .locked
```

The operators are shorthand for the underlying methods:

| Operator | Method |
| --- | --- |
| `machine <<~ (event, source, destination)` | `add(transition:)` |
| `machine ~>> event` | `process(event:)` |

### React to transitions

```swift
turnstile.onEnter = { transition in
	print("entered \(transition.destination) via \(transition.event)")
}

turnstile.onExit = { transition in
	print("left \(transition.destination)")
}
```

When an event is processed, `onExit` is called with the previously performed transition, then the state changes, then `onEnter` is called with the new one.

## Behavior notes

- **Unknown events are ignored.** If no transition exists for the event in the current state, `process(event:)` does nothing and `current` stays the same.
- **No ambiguity.** `add(transition:)` throws if a transition with the same event and source state already exists, so every `(state, event)` pair leads to at most one destination.
- **Not thread-safe.** A machine is meant to have a single owner. If you share one across threads or tasks, protect access yourself, for example by confining it to `@MainActor` or an actor of your own.

## More examples

The [tests](Tests/StateMachineTests) include two textbook state machines you can use as a reference:

- a coin-operated turnstile
- the [Border Gateway Protocol](https://en.wikipedia.org/wiki/Border_Gateway_Protocol#/media/File:BGP_FSM.svg) session setup

## Development

```
swift build
swift test
```

Tests are written with [Swift Testing](https://developer.apple.com/documentation/testing).

## License

GPL-3.0. See [LICENSE](LICENSE).
