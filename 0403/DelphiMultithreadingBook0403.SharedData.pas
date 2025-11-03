unit DelphiMultithreadingBook0403.SharedData;

interface

uses
  System.SyncObjs;

var
  // Event to control the pausing/resuming of pausable threads
  PauseEvent: TEvent;

implementation

initialization
  // Initialize the pause event
  PauseEvent := TEvent.Create(
    nil,
    True,  // ManualReset = True
    True,  // InitialState = True (Signaled, not paused)
    'PauseEvent',
    False);

finalization
  PauseEvent.Free;

end.
