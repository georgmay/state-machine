import Foundation

@testable import StateMachine
import Quick
import Nimble

class StateMachineSpec: QuickSpec {
	override func spec() {
		describe("StateMachine") {
			// Read more:
			// https://en.wikipedia.org/wiki/Finite-state_machine#Example:_coin-operated_turnstile
			describe("textbook coin-operated turnstile example") {
				enum Event {
					case coin
					case push
				}
				
				enum State {
					case locked
					case unlocked
				}
				
				var stateMachine: FiniteStateMachine<State, Event>!
				
				beforeEach {
					stateMachine = FiniteStateMachine<State, Event>(default: .locked)
					
					stateMachine <<~ (.coin, .locked, .unlocked)
					stateMachine <<~ (.coin, .unlocked, .unlocked)
					stateMachine <<~ (.push, .unlocked, .locked)
					stateMachine <<~ (.push, .locked, .locked)
				}
				
				it("must perform transit from `locked` to `unlocked` state for `coin` event") {
					// When
					stateMachine ~>> .coin
					
					// Then
					expect(stateMachine.current).to(
						equal(.unlocked),
						description: "Unlocks the turnstile so that the customer can push through."
					)
				}
				
				it("must perform transition from `locked` to `locked` state for `push` event") {
					// When
					stateMachine ~>> .push
					
					// Then
					expect(stateMachine.current).to(
						equal(.locked),
						description: "Keeps the lock."
					)
				}
				
				it("must perform transition from `unlocked` to `locked` state for `push` event") {
					// Given
					stateMachine ~>> .coin
					
					expect(stateMachine.current).to(
						equal(.unlocked),
						description: "Unlocks the turnstile so that the customer can push through."
					)
					
					// When
					stateMachine ~>> .push
					
					// Then
					expect(stateMachine.current).to(
						equal(.locked),
						description: "When the customer has pushed through, locks the turnstile."
					)
				}
				
				it("must perform transition from `unlocked` to `unlocked` state for `coin` event") {
					// Given
					stateMachine ~>> .coin
					
					expect(stateMachine.current).to(
						equal(.unlocked),
						description: "Unlocks the turnstile so that the customer can push through."
					)
					
					// When
					stateMachine ~>> .coin
					
					// Then
					expect(stateMachine.current).to(
						equal(.unlocked),
						description: "New coin will not affect the state and would keep the tunstile open."
					)
				}
			}
			
			// https://en.wikipedia.org/wiki/Border_Gateway_Protocol#/media/File:BGP_FSM.svg
			describe("textbook border gateway protocol state machine") {
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
				
				var stateMachine: FiniteStateMachine<State, Event>!
				
				beforeEach {
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
				
				it("must perform transition from `idle` to `established` state when BGP goes with successful flow") {
					// When
					stateMachine ~>> .connectionSucceeded
					stateMachine ~>> .openSucceeded
					stateMachine ~>> .sendKeepAliveSucceeded
					stateMachine ~>> .keepAliveValid
					
					// Then
					expect(stateMachine.current).to(
						equal(.established),
						description: "Performs successful BGP initialization."
					)
				}
				
				it("must perform transition from `idle` to `established` state when BGP goes through a bit bumpy road") {
					// When
					stateMachine ~>> .connectionSucceeded
					stateMachine ~>> .openFailed
					stateMachine ~>> .retryOpenSucceeded
					stateMachine ~>> .sendKeepAliveSucceeded
					stateMachine ~>> .keepAliveValid
					
					// Then
					expect(stateMachine.current).to(
						equal(.established),
						description: "Performs successful BGP initialization."
					)
				}
				
				it("must perform transition from `idle` to `idle` state when invalid `KeepAlive` package received") {
					// When
					stateMachine ~>> .connectionSucceeded
					stateMachine ~>> .openFailed
					stateMachine ~>> .retryOpenSucceeded
					stateMachine ~>> .sendKeepAliveSucceeded
					stateMachine ~>> .keepAliveWrong
					
					// Then
					expect(stateMachine.current).to(
						equal(.idle),
						description: "BGP fails."
					)
				}
				
				it("must perform transition from `idle` to `idle` state when invalid `Open` package received") {
					// When
					stateMachine ~>> .connectionSucceeded
					stateMachine ~>> .openFailed
					stateMachine ~>> .retryOpenSucceeded
					stateMachine ~>> .sendKeepAliveFailed

					// Then
					expect(stateMachine.current).to(
						equal(.idle),
						description: "BGP fails."
					)
				}
			}
		}
	}
}
