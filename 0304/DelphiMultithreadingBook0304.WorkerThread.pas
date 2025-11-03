unit DelphiMultithreadingBook0304.WorkerThread;

interface

uses
  System.Classes, DelphiMultithreadingBook.Utils;

type
  TWorkerThread = class(TThread)
  private
    FLogWriteCallback: TLogWriteCallback;
    FThreadID: Integer;
  protected
    procedure Execute; override;
    procedure CallbackLogWrite(const Text: string); overload;
    procedure CallbackLogWrite(const Text: string; const Args: array of const); overload;
  public
    constructor Create(ThreadID: Integer; LogWriteCallback: TLogWriteCallback);
  end;

implementation

uses
  System.SyncObjs, System.SysUtils, WinApi.Windows,
  DelphiMultithreadingBook0304.SharedData;

{ TWorkerThread }

constructor TWorkerThread.Create(ThreadID: Integer; LogWriteCallback: TLogWriteCallback);
begin
  inherited Create(False);
  FreeOnTerminate := True;
  FThreadID := ThreadID;
  FLogWriteCallback := LogWriteCallback;
end;

procedure TWorkerThread.Execute;
var
  i: Integer;
begin
  CallbackLogWrite('Thread %d: Starting...', [FThreadID]);
  CallbackLogWrite('Thread %d: Trying to acquire Semaphore permit...', [FThreadID]);
  // Acquire a permit from the Semaphore
  // Blocks if there are no permits available
  WorkerSemaphore.Acquire;
  try
    CallbackLogWrite('Thread %d: Semaphore permit acquired! Starting processing...',
      [FThreadID]);
    // Simulate real heavy processing
    for i := 1 to 3 do
    begin
      if Terminated then
        Break;
      CallbackLogWrite('Thread %d: Processing step %d...', [FThreadID, i]);
      // Takes 1 second per step
      Sleep(1000);
    end;

    CallbackLogWrite('Thread %d: Heavy processing completed!', [FThreadID]);
  finally
    // Release the Semaphore permit
    WorkerSemaphore.Release;
    CallbackLogWrite('Thread %d: Semaphore permit released!', [FThreadID]);
  end;

  CallbackLogWrite('Thread %d: End of work.', [FThreadID]);
end;

procedure TWorkerThread.CallbackLogWrite(const Text: string; const Args: array of const);
begin
  CallbackLogWrite(Format(Text, Args));
end;

procedure TWorkerThread.CallbackLogWrite(const Text: string);
var
  Callback: TLogWriteCallback;
begin
  DebugLogWrite(Text);
  // Send log to the UI if the callback was provided
  if Assigned(FLogWriteCallback) then
  begin
    // Assign to a local variable to be safely captured by the closure
    Callback := FLogWriteCallback;
    // We use TThread.Queue to update the UI without blocking the processing
    TThread.Queue(nil,
      procedure
      begin
        Callback(Text);
      end);
  end;
end;

end.
