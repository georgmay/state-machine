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
					
					stateMachine <~ (.coin, .locked, .unlocked)
					stateMachine <~ (.coin, .unlocked, .unlocked)
					stateMachine <~ (.push, .unlocked, .locked)
					stateMachine <~ (.push, .locked, .locked)
				}
				
				it("must transition from `locked` to `unlocked` state for `coin` event") {
					// When
					stateMachine.process(event: .coin)
					
					// Then
					expect(stateMachine.current).to(
						equal(.unlocked),
						description: "Unlocks the turnstile so that the customer can push through."
					)
				}
				
				it("must transition from `locked` to `locked` state for `push` event") {
					// When
					stateMachine.process(event: .push)
					
					// Then
					expect(stateMachine.current).to(
						equal(.locked),
						description: "Keeps the lock."
					)
				}
				
				it("must transition from `unlocked` to `locked` state for `push` event") {
					// Given
					stateMachine.process(event: .coin)
					
					expect(stateMachine.current).to(
						equal(.unlocked),
						description: "Unlocks the turnstile so that the customer can push through."
					)
					
					// When
					stateMachine.process(event: .push)
					
					// Then
					expect(stateMachine.current).to(
						equal(.locked),
						description: "When the customer has pushed through, locks the turnstile."
					)
				}
				
				it("must transition from `unlocked` to `unlocked` state for `coin` event") {
					// Given
					stateMachine.process(event: .coin)
					
					expect(stateMachine.current).to(
						equal(.unlocked),
						description: "Unlocks the turnstile so that the customer can push through."
					)
					
					// When
					stateMachine.process(event: .coin)
					
					// Then
					expect(stateMachine.current).to(
						equal(.unlocked),
						description: "New coin will not affect the state and would keep the tunstile open."
					)
				}
			}
		}
	}
}
