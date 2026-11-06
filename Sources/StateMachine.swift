import Foundation

enum StateMachineError: Swift.Error, Equatable {
	case divergenceAttempt
	case noTransition
}

protocol StateMachine: AnyObject {
	associatedtype State: Hashable
	associatedtype Event: Hashable

	var current: State { get }

	func process(event: Event)
	func add(transition: Transition<State, Event>) throws
}
