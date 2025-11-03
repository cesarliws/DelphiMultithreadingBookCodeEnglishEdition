unit DelphiMultithreadingBook0308.Worker;

interface

uses
  System.Classes, System.SyncObjs, DelphiMultithreadingBook.Utils;

type
  TWorkerWithCancel = class(TThread)
  private
    FCancelEvent: TEvent;
  protected
    procedure Execute; override;
  public
    constructor Create;
    destructor Destroy; override;
    property CancelEvent: TEvent read FCancelEvent;
  end;

implementation

uses
  System.SysUtils;

constructor TWorkerWithCancel.Create;
begin
  inherited Create(True); // Create suspended
  FreeOnTerminate := False;
  // Manual-reset event, starts non-signaled
  FCancelEvent := TEvent.Create(nil, True, False, '');
end;

destructor TWorkerWithCancel.Destroy;
begin
  FCancelEvent.Free;
  inherited;
end;

procedure TWorkerWithCancel.Execute;
begin
  LogWrite('Worker: Starting long task (5 seconds)...');
  // Waits for 5 seconds, but can be interrupted by CancelEvent at any time.
  // WaitFor returns wrSignaled if the event is signaled, or wrTimeout if the time runs out.
  if FCancelEvent.WaitFor(5000) = wrTimeout then
    LogWrite('Worker: Task completed successfully!')
  else
    LogWrite('Worker: Task interrupted by cancellation.');
end;

end.
