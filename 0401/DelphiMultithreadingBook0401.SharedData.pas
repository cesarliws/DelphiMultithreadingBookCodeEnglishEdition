unit DelphiMultithreadingBook0401.SharedData;

interface

uses
  System.Classes, System.SyncObjs;

var
  // Event to control the pausing/resuming of pausable threads
  PauseEvent: TEvent;

implementation

uses
  System.SysUtils;

initialization
  // Initializes the pause event:
  PauseEvent := TEvent.Create(
    nil,         // EventAttributes = nil
    True,        // ManualReset = True
    True,        // InitialState = True (Signaled, Not Paused)
    'PauseEvent',// Name
    False        // UseCOMWait = False
  );

finalization
  PauseEvent.Free;

end.
