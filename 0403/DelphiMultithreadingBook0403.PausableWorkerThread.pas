unit DelphiMultithreadingBook0403.PausableWorkerThread;

interface

uses
  System.Classes, DelphiMultithreadingBook.CancellationToken;

type
  TPausableWorkerThread = class(TThread)
  private
    FThreadID: Integer;
    // The cancellation token
    FCancellationToken: ICancellationToken;
  protected
    procedure Execute; override;
  public
    constructor Create(ThreadID: Integer; CancellationToken: ICancellationToken);
  end;

implementation

uses
  System.SyncObjs, System.SysUtils, WinApi.Windows,
  DelphiMultithreadingBook0403.SharedData, DelphiMultithreadingBook.Utils;

{ TPausableWorkerThread }

constructor TPausableWorkerThread.Create(ThreadID: Integer; CancellationToken: ICancellationToken);
begin
  inherited Create(False);
  FreeOnTerminate := False;
  FThreadID := ThreadID;
  FCancellationToken := CancellationToken;
end;

procedure TPausableWorkerThread.Execute;
var
  i: Integer;
begin
  DebugLogWrite('PausableThread %d: Starting work...', [FThreadID]);
  // Protect the entire execution block to catch the cancellation exception
  try
    // First cancellation check before starting the main loop
    FCancellationToken.ThrowIfCancellationRequested;
    for i := 1 to 15 do // Simulate 15 work steps
    begin
      // --- Pause Checkpoint (kept from 4.1) ---
      // The thread can also be paused and still check for cancellation
      DebugLogWrite('PausableThread %d: Waiting for PAUSE/RESUME signal...', [FThreadID]);
      // Use the ICancellationToken's WaitForCancellation
      if PauseEvent.WaitFor(100) = TWaitResult.wrTimeout then
      begin
        while (PauseEvent.WaitFor(100) = TWaitResult.wrTimeout) and
          // Check the cancellation token here
          (not FCancellationToken.IsCancellationRequested) do
        begin
          DebugLogWrite('PausableThread %d: Paused...', [FThreadID]);
        end;
        // If it exited the pause loop because cancellation was requested
        if FCancellationToken.IsCancellationRequested then Break;
      end;
      // --- End of Pause Checkpoint ---
      // --- Cancellation Checkpoint ---
      // Check the cancellation token at safe points in the work.
      // The ThrowIfCancellationRequested call will raise an exception if cancelled.
      // This simplifies the logic for exiting the loop.
      FCancellationToken.ThrowIfCancellationRequested;
      DebugLogWrite('PausableThread %d: Executing step %d...', [FThreadID, i]);
      // Simulate work
      Sleep(500);
    end;
    DebugLogWrite('PausableThread %d: Work completed!', [FThreadID]);
  except
    // Catch the cancellation exception
    on E: EOperationCancelled do
    begin
      DebugLogWrite('PausableThread %d: Operation CANCELLED: %s', [FThreadID, E.Message]);
      // Cleanup actions specific to cancellation can go here
    end;
    // Catch other unexpected exceptions
    on E: Exception do
    begin
      DebugLogWrite('PausableThread %d: UNEXPECTED ERROR: %s', [FThreadID, E.Message]);
      // Error handling logic for other exceptions (topic 4.5)
    end;
  end;
end;

end.
