unit DelphiMultithreadingBook0301.WorkerThread;

interface

uses
  System.Classes;

type
  TWorkerThread = class(TThread)
  private
    FActionCount: Integer;
    FThreadID: Integer;
  protected
    procedure Execute; override;
  public
    constructor Create(ThreadID: Integer; ActionCount: Integer);
  end;

implementation

uses
  System.SyncObjs, System.SysUtils,
  DelphiMultithreadingBook0301.SharedData, DelphiMultithreadingBook.Utils;

{ TWorkerThread }

constructor TWorkerThread.Create(ThreadID: Integer; ActionCount: Integer);
begin
  inherited Create(False);
  FreeOnTerminate := True;
  FThreadID := ThreadID;
  FActionCount := ActionCount;
end;

procedure TWorkerThread.Execute;
var
  i: Integer;
  ThreadMessage: string;
begin
  DebugLogWrite('Thread %d: Starting work...', [FThreadID]);
  for i := 1 to FActionCount do
  begin
    // The Terminated property allows us to interrupt the loop's execution
    // safely and cooperatively, in case the thread needs to be terminated.
    if Terminated then
      Break;
    // Protects the write to the SharedStringList with the Critical Section
    // --- Start of Critical Section ---
    SharedStringListCriticalSection.Enter;
    try
      // Only one thread at a time can execute the code inside here
      ThreadMessage := Format('Thread %d: Adding item %d', [FThreadID, i]);
      SharedStringList.Add(ThreadMessage);
    finally
      SharedStringListCriticalSection.Leave;
    end;
    // --- End of Critical Section ---

    // Debug logging is thread-safe and can be done outside the lock
    DebugLogWrite(ThreadMessage);
    // Short pause to simulate real work and allow context switching
    Sleep(10);
  end;
  DebugLogWrite('Thread %d: Work completed!', [FThreadID]);
end;

end.
