import Foundation

precedencegroup BindingPrecedence {
  associativity: right
	
	higherThan: AssignmentPrecedence
}

infix operator ~>>: BindingPrecedence
infix operator <<~: BindingPrecedence

public extension FiniteStateMachine {
	static func ~>> (lhs: FiniteStateMachine, rhs: Event) {
		lhs.process(event: rhs)
  }
	
	static func <<~ (lhs: FiniteStateMachine, rhs: (Event, State, State)) {
		let (event, source, destination) = rhs
		
		let transition = Transition(with: event, from: source, to: destination)
		try! lhs.add(transition: transition)
	}
}
