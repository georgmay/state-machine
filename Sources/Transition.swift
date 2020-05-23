import Foundation

public class Transition<State, Event> {
  public enum Result {
    case success
    case failure
  }
  
  public typealias ExecutionBlock = ((State) -> Void)
  
  public let event: Event
  public let source: State
  public let destination: State
  
  private var enterBlock: ExecutionBlock?
  private var exitBlock: ExecutionBlock?
  
  public init(
    with event: Event,
    from source: State,
    to destination: State
  ) {
    self.event = event
    self.source = source
    self.destination = destination
  }
  
  func setEnterHandler(enterBlock: ExecutionBlock?) {
    self.enterBlock = enterBlock
  }
  
  func setExitHandler(exitBlock: ExecutionBlock?) {
    self.exitBlock = exitBlock
  }
  
  func performEnter() {
    enterBlock?(source)
  }
  
  func performExit() {
    exitBlock?(destination)
  }
}
