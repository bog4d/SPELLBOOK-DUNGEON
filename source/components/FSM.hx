package components;

class FSM
{
	public var currentState:Float->Void;

	public function new(initialState:Float->Void):Void
		currentState = initialState;

	public function setState(newState:Float->Void):Void
		currentState = newState;

	public function update(elapsed:Float):Void
		currentState(elapsed);
}
