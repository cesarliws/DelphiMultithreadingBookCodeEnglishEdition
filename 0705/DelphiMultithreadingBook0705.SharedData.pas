unit DelphiMultithreadingBook0705.SharedData;

interface

uses
  System.Generics.Collections,
  System.SyncObjs,
  System.SysUtils;

var
  QueueLock: TCriticalSection;
  WorkQueue: TQueue<string>;
  QueueNotEmpty: TConditionVariableCS;

implementation

initialization
  QueueLock := TCriticalSection.Create;
  WorkQueue := TQueue<string>.Create;
  QueueNotEmpty := TConditionVariableCS.Create;

finalization
  QueueNotEmpty.Free;
  WorkQueue.Free;
  QueueLock.Free;

end.
