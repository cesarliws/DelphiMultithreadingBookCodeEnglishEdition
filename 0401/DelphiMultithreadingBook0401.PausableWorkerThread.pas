unit DelphiMultithreadingBook0401.PausableWorkerThread;

interface

uses
  System.Classes,
  DelphiMultithreadingBook0401.SharedData,
  DelphiMultithreadingBook.Utils;

type
  TPausableWorkerThread = class(TThread)
  private
    FLogWriteCallback: TLogWriteCallback;
    FWorkerID: Integer;
  protected
    procedure Execute; override;
    procedure TerminatedSet; override;
  public
    constructor Create(WorkerID: Integer; LogWriteCallback: TLogWriteCallback); reintroduce;
  end;

implementation

uses
  System.SyncObjs, System.SysUtils;

{ TPausableWorkerThread }

constructor TPausableWorkerThread.Create(WorkerID: Integer;
  LogWriteCallback: TLogWriteCallback);
begin
  inherited Create(False);
  FreeOnTerminate := False;
  FWorkerID := WorkerID;
  FLogWriteCallback := LogWriteCallback;
end;

procedure TPausableWorkerThread.Execute;
var
  i: Integer;
  LogMessage: string;
begin
  DebugLogWrite('PausableThread %d: Starting work...', [FWorkerID]);
  // Simulate 15 steps of work
  for i := 1 to 15 do
  begin
    // --- Pause Checkpoint (Safe Point) ---
    DebugLogWrite('PausableThread %d: Waiting for PAUSE/RESUME signal...', [FWorkerID]);
    // WaitFor waits for the event to be signaled. If PauseEvent is Reset (non-signaled),
    // the thread pauses here. We use a short timeout so we can also check 'Terminated'
    // and avoid an eternal block. If a timeout occurs, it means the event is reset
    // (a pause was requested). It enters a wait loop until the event is Set again,
    // while still checking the Terminate condition to allow for a graceful stop.
    while (PauseEvent.WaitFor(100) = TWaitResult.wrTimeout) and (not Terminated) do
    begin
      DebugLogWrite('PausableThread %d: Paused...', [FWorkerID]);
      // The thread is paused but can still be terminated.
    end;
    // --- End of Pause Checkpoint ---
    // Check Terminated again after the pause check
    if Terminated then
      Break;
    LogMessage := Format('PausableThread %d: Executing step %d...', [FWorkerID, i]);
    // The callback provides visual feedback to the user that the thread is running.
    if Assigned(FLogWriteCallback) then
      TThread.Queue(nil, procedure
        begin
          FLogWriteCallback(LogMessage);
        end);
    DebugLogWrite(LogMessage);
    // Simulate work for this step
    Sleep(500);
  end;
  DebugLogWrite('PausableThread %d: Work completed!', [FWorkerID]);
end;

procedure TPausableWorkerThread.TerminatedSet;
begin
  inherited;
  // This is the key: signal the event to wake up the thread from its WaitFor
  PauseEvent.SetEvent;
end;

end.
