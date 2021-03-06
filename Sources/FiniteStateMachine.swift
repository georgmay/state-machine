import Foundation

public class FiniteStateMachine<State: Hashable, Event: Hashable>: StateMachine {
	enum Error: Swift.Error, Equatable {
		case divergenceAttempt
		case noTransition
	}
	
	public var current: State
  public var onEnter: ((Transition<State, Event>) -> Void)?
  public var onExit: ((Transition<State, Event>) -> Void)?
	
	// https://en.wikipedia.org/wiki/State-transition_table
	private var transitionsByEvent: [Event: [Transition<State, Event>]]
	private var lastTransition: Transition<State, Event>?
	
	public init(`default`: State) {
		current = `default`
		
		transitionsByEvent = [:]
	}
	
  public func process(event: Event) {
		guard let transition = findTransition(for: event, initiating: current) else {
			return
		}
		
		if let last = lastTransition {
      onExit?(last)
      last.performExit()
    }
		
		current = transition.destination
    onEnter?(transition)
		transition.performEnter()
    
		lastTransition = transition
  }
  
	public func add(transition: Transition<State, Event>) throws {
		guard findTransition(for: transition.event, initiating: transition.source) == nil else {
			throw Error.divergenceAttempt
		}

		transitionsByEvent[
			transition.event,
			default: []
		].append(transition)
  }
	
	private func findTransition(for event: Event, initiating state: State) -> Transition<State, Event>? {
		let allEventTransitions = transitionsByEvent[event, default: []]
		return allEventTransitions.first { $0.source == state }
	}
}
