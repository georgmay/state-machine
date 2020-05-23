import Foundation

protocol StateMachine: class {
	associatedtype State: Hashable
	associatedtype Event: Hashable
	
	var current: State { get }
	
	func process(event: Event)
	func add(transition: Transition<State, Event>) throws
}
