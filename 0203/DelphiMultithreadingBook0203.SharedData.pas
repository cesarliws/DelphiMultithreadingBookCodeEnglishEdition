unit DelphiMultithreadingBook0203.SharedData;

interface

uses
  System.Classes,
  System.SyncObjs;

var
  GlobalCounter: Integer;
  CounterLock: TCriticalSection;

implementation

initialization
  GlobalCounter := 0;
  CounterLock := TCriticalSection.Create;

finalization
  CounterLock.Free;

end.
