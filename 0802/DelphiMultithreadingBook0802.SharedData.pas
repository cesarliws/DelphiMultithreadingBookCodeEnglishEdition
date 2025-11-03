unit DelphiMultithreadingBook0802.SharedData;

interface

uses
  System.SyncObjs;

var
  // For tests 1 and 2
  GlobalCounter: Int64;
  CounterLock: TCriticalSection;
  // For test 3 (optimized) - Final total, where subtotals will be summed
  FinalGlobalCounter: Int64;

threadvar
  // Each thread will have its own copy of this variable. There is no sharing.
  LocalCounter: Int64;

implementation

initialization
  CounterLock := TCriticalSection.Create;

finalization
  CounterLock.Free;

end.
