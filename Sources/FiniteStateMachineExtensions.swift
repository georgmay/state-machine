import Foundation

precedencegroup ProcessEventPrecedence {
  associativity: left
}

precedencegroup AddTransitionPrecedence {
	associativity: left
}

infix operator ~>: ProcessEventPrecedence
infix operator <~: AddTransitionPrecedence

extension FiniteStateMachine {
	static func ~> (lhs: FiniteStateMachine, rhs: Event) {
		lhs.process(event: rhs)
  }
	
	static func <~ (lhs: FiniteStateMachine, rhs: (Event, State, State)) {
		let (event, source, destination) = rhs
		
		let transition = Transition(with: event, from: source, to: destination)
		try! lhs.add(transition: transition)
	}
}
