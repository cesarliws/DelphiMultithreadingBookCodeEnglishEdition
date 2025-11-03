unit DelphiMultithreadingBook0405.WorkerWithErrorThread;

interface

uses
  System.Classes, System.SysUtils;

type
  // Thread that handles exceptions
  TWorkerWithErrorThread = class(TThread)
  private
    // Field to store the captured exception
    FError: Exception;
  protected
    procedure Execute; override;
  public
    constructor Create;
    destructor Destroy; override;
    // Property to access the error (read-only)
    property Error: Exception read FError;
  end;

implementation

uses
  DelphiMultithreadingBook.Utils;

{ TWorkerWithErrorThread }

constructor TWorkerWithErrorThread.Create;
begin
  inherited Create(False);
  // The thread will free itself when it finishes
  FreeOnTerminate := True;
end;

destructor TWorkerWithErrorThread.Destroy;
begin
  if Assigned(FError) then
    FError.Free;
  inherited;
end;

procedure TWorkerWithErrorThread.Execute;
var
  // Temporary variable for the exception
  ExceptionObject: TObject;
  Divisor: Integer;
  i: Integer;
  Value: Integer;
begin
  // Clear any previous error
  FError := nil;
  try
    for i := 0 to 10 do
    begin
      LogWrite('WorkerWithErrorThread: Starting work...');
      // Simulate work
      Sleep(1000);
      // Can be 0 or 1
      Divisor := Random(2);
      if Divisor = 0 then
      begin
        LogWrite('WorkerWithErrorThread: Attempting to divide by zero...');
        // Forces an EDivByZero exception
        Value := 100 div Divisor;
        LogWrite('WorkerWithErrorThread: Division successful 100 / %d = %d', [Divisor, Value]);
      end
      else
        LogWrite('WorkerWithErrorThread: Division performed successfully.');
    end;
    LogWrite('WorkerWithErrorThread: Work completed successfully.');
  except
    on E: Exception do
    begin
      // **CRITICAL:** Acquire the exception object to ensure it is not
      // automatically freed at the end of the 'except' block in the worker thread.
      // This allows the exception object to be safely accessed in the
      // main thread.
      ExceptionObject := AcquireExceptionObject;
      // Stores the captured exception in the thread's field.
      // The 'E' object is the same as 'ExceptionObject' at this point, but 'ExceptionObject'
      // ensures the reference count is incremented.
      FError := Exception(ExceptionObject);
      LogWrite('WorkerWithErrorThread: Exception caught: %s', [E.Message]);
      // We DO NOT re-raise the exception, as it has been "handled" to be reported.
    end;
  end;
end;

end.
