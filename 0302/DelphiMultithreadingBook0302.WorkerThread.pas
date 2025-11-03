unit DelphiMultithreadingBook0302.WorkerThread;

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
  System.SyncObjs, System.SysUtils, WinApi.Windows,
  DelphiMultithreadingBook0302.SharedData, DelphiMultithreadingBook.Utils;

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
    if Terminated then
      Break;
    // --- Start of TMonitor Protection ---
    // Protects the SharedStringList instance
    TMonitor.Enter(SharedStringList);
    try
      ThreadMessage := Format('Thread %d (Monitor): Adding item %d', [FThreadID, i]);
      SharedStringList.Add(ThreadMessage);
      // Optional: to see in the Debug Output
      DebugLogWrite(ThreadMessage);
    finally
      TMonitor.Exit(SharedStringList);
    end;
    // --- End of TMonitor Protection ---

    // Short pause
    Sleep(10);
  end;
  DebugLogWrite('Thread %d: Work completed!', [FThreadID]);
end;

end.
