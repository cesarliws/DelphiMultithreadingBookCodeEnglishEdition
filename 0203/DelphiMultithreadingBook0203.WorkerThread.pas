unit DelphiMultithreadingBook0203.WorkerThread;

interface

uses
  System.Classes;

type
  TWorkerThread = class(TThread)
  private
    FUseLocking: Boolean;
    FIncrementCount: Integer;
  protected
    procedure Execute; override;
  public
    constructor Create(UseLocking: Boolean; IncrementCount: Integer);
  end;

implementation

uses
  System.SyncObjs, System.SysUtils, DelphiMultithreadingBook0203.SharedData;

constructor TWorkerThread.Create(UseLocking: Boolean; IncrementCount: Integer);
begin
  // Creates the thread suspended
  inherited Create(True);
  // Manual management by the orchestrator
  FreeOnTerminate := False;
  FUseLocking := UseLocking;
  FIncrementCount := IncrementCount;
end;

procedure TWorkerThread.Execute;
var
  i: Integer;
begin
  for i := 1 to FIncrementCount do
  begin
    if FUseLocking then
    begin
      CounterLock.Enter;
      try
        GlobalCounter := GlobalCounter + 1;
      finally
        CounterLock.Leave;
      end;
    end
    else
    begin
      // Unsafe access - prone to Race Condition
      GlobalCounter := GlobalCounter + 1;
    end;
  end;
end;

end.
