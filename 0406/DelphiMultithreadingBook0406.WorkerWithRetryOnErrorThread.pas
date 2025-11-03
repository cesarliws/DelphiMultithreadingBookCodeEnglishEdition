unit DelphiMultithreadingBook0406.WorkerWithRetryOnErrorThread;

interface

uses
  System.Classes, System.Generics.Collections, System.SysUtils, System.Threading,
  DelphiMultithreadingBook.Utils;

type
  TWorkerWithRetryOnErrorThread = class(TThread)
  private
    FCurrentRetry: Integer;
    FDelayMs: Integer;
    FError: EAggregateException;
    FErrors: TObjectList<Exception>;
    FInitialDelayMs: Integer;
    FMaxRetries: Integer;
  protected
    procedure Execute; override;
    procedure ExecuteWorkWithRetryOnError; virtual;
    // Method that attempts the operation
    function RunDivisionCalculation: Boolean;
  public
    constructor Create(MaxRetries: Integer = 3; InitialDelayMs: Integer = 500);
    destructor Destroy; override;
    property Error: EAggregateException read FError;
  end;

implementation

{ TWorkerWithRetryOnErrorThread }

constructor TWorkerWithRetryOnErrorThread.Create(MaxRetries: Integer = 3;
  InitialDelayMs: Integer = 500);
begin
  inherited Create(False);
  // Manual memory management (FreeOnTerminate = False) to ensure that
  // we can safely call WaitFor in the MainForm.
  FreeOnTerminate := False;
  FMaxRetries := MaxRetries;
  FInitialDelayMs := InitialDelayMs;
  FCurrentRetry := 0;
  // AOwnsObjects = False, Error: EAggregateException will free the exceptions
  FErrors := TObjectList<Exception>.Create(False);
end;

destructor TWorkerWithRetryOnErrorThread.Destroy;
begin
  // Frees the list of collected exceptions
  FErrors.Free;
  // Frees the EAggregateException object if it was created
  if Assigned(FError) then
    FError.Free;
  inherited;
end;

procedure TWorkerWithRetryOnErrorThread.Execute;
var
  ExceptionObject: TObject;
begin
  try
    LogWrite('Retry thread: Starting work...');
    Sleep(100); // Small initial pause
    FCurrentRetry := 0;
    FDelayMs := FInitialDelayMs;
    // Calls the method with the retry loop
    ExecuteWorkWithRetryOnError;
    // After the loop, if there are collected errors, create the aggregate exception.
    if FErrors.Count > 0 then
    begin
      // The EAggregateException takes ownership of the exceptions
      FError := EAggregateException.Create(FErrors.ToArray);
      // The FErrors list should no longer own the objects.
      FErrors.OwnsObjects := False;
    end;
  except
    on E: Exception do
    begin
      LogWrite('Retry thread: Fatal exception in Execute: %s', [E.Message]);
      // Catches an unexpected exception within Execute itself
      ExceptionObject := AcquireExceptionObject;
      if ExceptionObject is EAggregateException then
        FError := EAggregateException(ExceptionObject)
      else
        FError := EAggregateException.Create([Exception(ExceptionObject)]);
    end;
  end;
  LogWrite('Retry thread: End of work cycle.');
end;

procedure TWorkerWithRetryOnErrorThread.ExecuteWorkWithRetryOnError;
begin
  while (not Terminated) and (FCurrentRetry <= FMaxRetries) do
  begin
    Inc(FCurrentRetry);
    LogWrite('Retry thread: Attempt %d of %d',
      [FCurrentRetry, FMaxRetries]);

    // Attempts to execute the operation
    if RunDivisionCalculation then
    begin
      LogWrite('Retry thread: Operation finished successfully!');
      // Exits the loop if the operation was successful
      Break;
    end
    else // The operation failed
    begin
      // Checks for cancellation before the next iteration
      if Terminated then
        Break;

      // If there are still attempts remaining
      if FCurrentRetry <= FMaxRetries then
      begin
        LogWrite('Retry thread: Attempt %d failed. Waiting %d ms to retry...',
          [FCurrentRetry, FDelayMs]);

        // Simulates Exponential Backoff
        Sleep(FDelayMs);
        // Doubles the wait time for the next attempt
        FDelayMs := FDelayMs * 2;
        // Optional: Add a maximum limit for FDelayMs, and a jitter
        // (Random(FDelayMs div 10)) to avoid peaks
      end
      else // All attempts have been exhausted
      begin
        LogWrite('Retry thread: All %d attempts have failed.', [FMaxRetries]);
        // The FError is already filled by the last failure
      end;
    end;
  end;
end;

function TWorkerWithRetryOnErrorThread.RunDivisionCalculation: Boolean;
var
  Divisor: Integer;
  Value: Integer;
begin
  // Assume failure
  Result := False;
  try
    // Random(2) returns 0 or 1. If it is 0, it causes a division by zero.
    Divisor := Random(2);
    if Divisor = 0 then
    begin
      LogWrite('Error thread (Retry %d): Attempting to divide by zero...', [FCurrentRetry]);
      // Forces an EDivByZero exception
      Value := 100 div Divisor;
      // The next line will never be executed,
      // the flow is interrupted by the division by zero
      LogWrite('Error thread (Retry %d): Result = %d', [Value]);
    end
    else
    begin
      LogWrite('Error thread (Retry %d): Operation completed successfully.', [FCurrentRetry]);
      // Operation successful
      Result := True;
    end;
  except
    on E: Exception do
    begin
      LogWrite('Error thread (Retry %d): Exception caught: %s.', [FCurrentRetry, E.Message]);
      // CRITICAL: We use AcquireExceptionObject to store the exception safely, ensuring the
      // object is not freed by the RTL when exiting the except block, so we can free it later
      // with FErrors.
      FErrors.Add(AcquireExceptionObject as Exception);
      Result := False;
    end;
  end;
end;

end.
