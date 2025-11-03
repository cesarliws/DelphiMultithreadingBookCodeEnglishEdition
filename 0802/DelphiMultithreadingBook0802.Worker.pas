unit DelphiMultithreadingBook0802.Worker;

interface

uses
  System.Classes;

type
  TExecutionMode = (emNoSync, emCriticalSection, emThreadVar);

  TWorker = class(TThread)
  private
    FMode: TExecutionMode;
    FIncrementCount: Integer;
  protected
    procedure Execute; override;
  public
    constructor Create(Mode: TExecutionMode; IncrementCount: Integer);
  end;

implementation

uses
  System.SysUtils, System.SyncObjs, DelphiMultithreadingBook0802.SharedData;

constructor TWorker.Create(Mode: TExecutionMode; IncrementCount: Integer);
begin
  // Create suspended
  inherited Create(True);
  // Manual management by the form
  FreeOnTerminate := False;
  FMode := Mode;
  FIncrementCount := IncrementCount;
end;

procedure TWorker.Execute;
var
  i: Integer;
begin
  // The threadvar variable is initialized to zero for each thread.
  if FMode = emThreadVar then
  begin
    LocalCounter := 0;
  end;

  for i := 1 to FIncrementCount do
  begin
    case FMode of
      emNoSync:
        // UNSAFE ACCESS - Causes a Race Condition
        Inc(GlobalCounter);
      emCriticalSection:
        // Safe access, but with lock contention
        begin
          CounterLock.Enter;
          try
            Inc(GlobalCounter);
          finally
            CounterLock.Leave;
          end;
        end;
      emThreadVar:
        // Access the thread's local counter. No lock, no contention.
        Inc(LocalCounter);
    end;
  end;
  // If we are using threadvar, add the subtotal to the grand total at the end. This is the only
  // operation that needs synchronization. We use TInterlocked.Add as it is the most performant
  // way to perform an atomic addition, as we saw in detail in Topic 7.2.
  if FMode = emThreadVar then
  begin
    TInterlocked.Add(FinalGlobalCounter, LocalCounter);
  end;
end;

end.
