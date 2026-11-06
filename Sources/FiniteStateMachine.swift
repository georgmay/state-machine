import Foundation

public final class FiniteStateMachine<State: Hashable, Event: Hashable>: StateMachine {
	public private(set) var current: State
	public var onEnter: ((Transition<State, Event>) -> Void)?
	public var onExit: ((Transition<State, Event>) -> Void)?

	// https://en.wikipedia.org/wiki/State-transition_table
	private var transitionsByEvent: [Event: [Transition<State, Event>]]
	private var lastTransition: Transition<State, Event>?

	public init(`default`: State) {
		self.current = `default`
		self.transitionsByEvent = [:]
	}

	public func process(event: Event) {
		guard let transition = self.findTransition(for: event, initiating: current) else {
			return
		}

		if let last = self.lastTransition {
			self.onExit?(last)
			last.performExit()
		}

		self.current = transition.destination
		self.onEnter?(transition)
		transition.performEnter()

		self.lastTransition = transition
	}

	public func add(transition: Transition<State, Event>) throws {
		guard self.findTransition(for: transition.event, initiating: transition.source) == nil else {
			throw StateMachineError.divergenceAttempt
		}

		self.transitionsByEvent[transition.event, default: []].append(transition)
	}

	private func findTransition(for event: Event, initiating state: State) -> Transition<State, Event>? {
		let allEventTransitions = self.transitionsByEvent[event, default: []]
		return allEventTransitions.first { $0.source == state }
	}
}
