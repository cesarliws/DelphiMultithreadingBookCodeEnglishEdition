unit DelphiMultithreadingBook0202.QueueOrSynchronizeThread;

interface

uses
  System.Classes, System.SysUtils, Vcl.StdCtrls;

type
  TInterfaceUpdateType = (Queue, Synchronize);

  TQueueOrSynchronizeThread = class(TThread)
  private
    FInterfaceUpdateType: TInterfaceUpdateType;
    // Reference to the Memo to demonstrate the coupling problem
    FLogMemoRef: TMemo;
  protected
    procedure Execute; override;
  public
    constructor Create(const LogMemo: TMemo; InterfaceUpdateType: TInterfaceUpdateType);
  end;

implementation

uses
  DelphiMultithreadingBook.Utils;

{ TQueueOrSynchronizeThread }

constructor TQueueOrSynchronizeThread.Create(const LogMemo: TMemo;
  InterfaceUpdateType: TInterfaceUpdateType);
begin
  inherited Create(False); // Starts the thread immediately
  FreeOnTerminate := True;
  FInterfaceUpdateType := InterfaceUpdateType;
  // We pass the Memo reference (direct coupling example for demonstration)
  FLogMemoRef := LogMemo;
end;

procedure TQueueOrSynchronizeThread.Execute;
var
  i: Integer;
  UpdateType: string;
begin
  if FInterfaceUpdateType = TInterfaceUpdateType.Queue then
    UpdateType := 'Queue'
  else
    UpdateType := 'Synchronize';

  DebugLogWrite('Thread (%s) started. Simulating heavy work...', [UpdateType]);
  // Short loop to see the updates
  for i := 1 to 5 do
  begin
    if Terminated then Break;
    // On each iteration, we send an update to the UI
    if FInterfaceUpdateType = TInterfaceUpdateType.Queue then
      Queue(procedure
        begin
          // WARNING: Direct access via FLogMemoRef.Lines.Add() creates coupling.
          // We use this for demonstration NOW, but we will improve it later!
          FLogMemoRef.Lines.Add(Format('Thread (%s): Progress %d of 5', [UpdateType, i]));
        end)
    else
      Synchronize(procedure
        begin
          // WARNING: Direct access via FLogMemoRef.Lines.Add() creates coupling.
          // We use this for demonstration NOW, but we will improve it later!
          FLogMemoRef.Lines.Add(Format('Thread (%s): Progress %d of 5', [UpdateType, i]));
        end);
    // 1-second pause to observe the progress
    Sleep(1000);
  end;
  // Only if the thread was not terminated prematurely
  if not Terminated then
  begin
    if FInterfaceUpdateType = TInterfaceUpdateType.Queue then
      Queue(procedure
        begin
          FLogMemoRef.Lines.Add(Format('Thread (%s) completed!', [UpdateType]));
        end)
    else
      Synchronize(procedure
        begin
          FLogMemoRef.Lines.Add(Format('Thread (%s) completed!', [UpdateType]));
        end);
  end
  else
    DebugLogWrite('Thread (%s) terminated prematurely.', [UpdateType]);
end;

end.
