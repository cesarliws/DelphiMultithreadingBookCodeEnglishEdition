unit DelphiMultithreadingBook0304.SharedData;

interface

uses
  System.Classes,
  System.SyncObjs;

var
  // New Semaphore to control the number of "working" threads
  WorkerSemaphore: TSemaphore;

implementation

initialization
  // Create the Semaphore:
  WorkerSemaphore := TSemaphore.Create(
    nil, // nil for default security attributes
    3,   // 3 initial permits
    3,   // 3 maximum permits (limits to 3 simultaneous workers)
    ''   // Empty name, creating a local (unnamed) semaphore
  );

finalization
  // Free the Semaphore
  WorkerSemaphore.Free;

end.
