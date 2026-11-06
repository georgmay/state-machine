import Foundation
import Testing
@testable import StateMachine

@Suite("StateMachine")
struct StateMachineTests {
	@Suite(
		"textbook coin-operated turnstile example",
		Comment("https://en.wikipedia.org/wiki/Finite-state_machine#Example:_coin-operated_turnstile")
	)
	struct TurnstileTests {
		enum Event {
			case coin
			case push
		}

		enum State {
			case locked
			case unlocked
		}

		// A fresh instance is created for every test (the equivalent of `beforeEach`).
		let stateMachine: FiniteStateMachine<State, Event>

		init() {
			stateMachine = FiniteStateMachine<State, Event>(default: .locked)

			stateMachine <<~ (.coin, .locked, .unlocked)
			stateMachine <<~ (.coin, .unlocked, .unlocked)
			stateMachine <<~ (.push, .unlocked, .locked)
			stateMachine <<~ (.push, .locked, .locked)
		}

		@Test("must perform transition from `locked` to `unlocked` state for `coin` event")
		func coinWhenLocked() {
			// When
			stateMachine ~>> .coin

			// Then
			#expect(
				stateMachine.current == .unlocked,
				"Unlocks the turnstile so that the customer can push through."
			)
		}

		@Test("must perform transition from `locked` to `locked` state for `push` event")
		func pushWhenLocked() {
			// When
			stateMachine ~>> .push

			// Then
			#expect(
				stateMachine.current == .locked,
				"Keeps the lock."
			)
		}

		@Test("must perform transition from `unlocked` to `locked` state for `push` event")
		func pushWhenUnlocked() {
			// Given
			stateMachine ~>> .coin

			#expect(
				stateMachine.current == .unlocked,
				"Unlocks the turnstile so that the customer can push through."
			)

			// When
			stateMachine ~>> .push

			// Then
			#expect(
				stateMachine.current == .locked,
				"When the customer has pushed through, locks the turnstile."
			)
		}

		@Test("must perform transition from `unlocked` to `unlocked` state for `coin` event")
		func coinWhenUnlocked() {
			// Given
			stateMachine ~>> .coin

			#expect(
				stateMachine.current == .unlocked,
				"Unlocks the turnstile so that the customer can push through."
			)

			// When
			stateMachine ~>> .coin

			// Then
			#expect(stateMachine.current == .unlocked,"New coin will not affect the state and would keep the turnstile open.")
		}
	}

	@Suite(
		"textbook border gateway protocol state machine",
		Comment("Read more: https://en.wikipedia.org/wiki/Border_Gateway_Protocol#/media/File:BGP_FSM.svg")
	)
	struct BGPTests {
		enum Event {
			case connectionSucceeded
			case connectionFailed

			case openFailed
			case openSucceeded

			case retryOpenSucceeded
			case retryOpenFailed

			case openMessageInvalid

			case sendKeepAliveSucceeded
			case sendKeepAliveFailed

			case keepAliveValid
			case keepAliveWrong
		}

		enum State {
			case idle
			case connect
			case active
			case openSent
			case openConfirm
			case established
		}

		let stateMachine: FiniteStateMachine<State, Event>

		init() {
			stateMachine = FiniteStateMachine<State, Event>(default: .idle)

			stateMachine <<~ (.connectionSucceeded, .idle, .connect)
			stateMachine <<~ (.connectionFailed, .connect, .idle)

			stateMachine <<~ (.openSucceeded, .connect, .openSent)
			stateMachine <<~ (.openFailed, .connect, .active)

			stateMachine <<~ (.retryOpenSucceeded, .active, .openSent)
			stateMachine <<~ (.retryOpenFailed, .active, .idle)

			stateMachine <<~ (.openMessageInvalid, .openSent, .idle)
			stateMachine <<~ (.sendKeepAliveFailed, .openSent, .idle)
			stateMachine <<~ (.sendKeepAliveSucceeded, .openSent, .openConfirm)

			stateMachine <<~ (.keepAliveValid, .openConfirm, .established)
			stateMachine <<~ (.keepAliveWrong, .openConfirm, .idle)
		}

		@Test("must perform transition from `idle` to `established` state when BGP goes with successful flow")
		func successfulFlow() {
			// When
			stateMachine ~>> .connectionSucceeded
			stateMachine ~>> .openSucceeded
			stateMachine ~>> .sendKeepAliveSucceeded
			stateMachine ~>> .keepAliveValid

			// Then
			#expect(
				stateMachine.current == .established,
				"Performs successful BGP initialization."
			)
		}

		@Test("must perform transition from `idle` to `established` state when BGP goes through a bit bumpy road")
		func bumpyRoad() {
			// When
			stateMachine ~>> .connectionSucceeded
			stateMachine ~>> .openFailed
			stateMachine ~>> .retryOpenSucceeded
			stateMachine ~>> .sendKeepAliveSucceeded
			stateMachine ~>> .keepAliveValid

			// Then
			#expect(
				stateMachine.current == .established,
				"Performs successful BGP initialization."
			)
		}

		@Test("must perform transition from `idle` to `idle` state when invalid `KeepAlive` package received")
		func invalidKeepAlive() {
			// When
			stateMachine ~>> .connectionSucceeded
			stateMachine ~>> .openFailed
			stateMachine ~>> .retryOpenSucceeded
			stateMachine ~>> .sendKeepAliveSucceeded
			stateMachine ~>> .keepAliveWrong

			// Then
			#expect(
				stateMachine.current == .idle,
				"BGP fails."
			)
		}

		@Test("must perform transition from `idle` to `idle` state when invalid `Open` package received")
		func invalidOpen() {
			// When
			stateMachine ~>> .connectionSucceeded
			stateMachine ~>> .openFailed
			stateMachine ~>> .retryOpenSucceeded
			stateMachine ~>> .sendKeepAliveFailed

			// Then
			#expect(stateMachine.current == .idle, "BGP fails.")
		}
	}
}
