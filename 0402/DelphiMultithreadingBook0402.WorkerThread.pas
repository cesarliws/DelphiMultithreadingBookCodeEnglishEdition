unit DelphiMultithreadingBook0402.WorkerThread;

interface

uses
  System.Classes;

type
  TWorkerThread = class(TThread)
  private
    FThreadID: Integer;
    FWorkPerformed: Integer;
  protected
    procedure Execute; override;
  public
    constructor Create(ThreadID: Integer);
    property WorkPerformed: Integer read FWorkPerformed;
  end;

implementation

uses
  DelphiMultithreadingBook.Utils;

{ TWorkerThread }

constructor TWorkerThread.Create(ThreadID: Integer);
begin
  inherited Create(True);
  // IMPORTANT: Manual management of the object's release
  FreeOnTerminate := False;
  FThreadID := ThreadID;
  FWorkPerformed := 0;
end;

procedure TWorkerThread.Execute;
var
  i: Integer;
begin
  DebugLogWrite('WorkerThread %d: Starting work...', [FThreadID]);
  // Long loop to simulate continuous work
  for i := 1 to 1000 do
  begin
    // Check if the thread has been requested to terminate
    if Terminated then
      // Exit the loop cooperatively
      Break;
    // Simulate work progress
    Inc(FWorkPerformed);
    // Short pause to allow context switching
    Sleep(1);
  end;
  DebugLogWrite('WorkerThread %d: Work completed (steps: %d)!', [FThreadID, FWorkPerformed]);
end;

end.
