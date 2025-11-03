unit DelphiMultithreadingBook0603.MainForm;

interface

uses
  System.Classes, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Vcl.Samples.Spin,
  System.Threading,   // TParallel.For, TTask, TLoopState
  DelphiMultithreadingBook.CancellationToken,
  DelphiMultithreadingBook.Utils;

type
  TMainForm = class(TForm)
    CalculatePrimesSequentiallyButton: TButton;
    CalculatePrimesInParallelButton: TButton;
    StopParallelCalculationButton: TButton;
    StopAfterCheckBox: TCheckBox;
    StopAfterSpinEdit: TSpinEdit;
    LogMemo: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure CalculatePrimesInParallelButtonClick(Sender: TObject);
    procedure CalculatePrimesSequentiallyButtonClick(Sender: TObject);
    procedure StopParallelCalculationButtonClick(Sender: TObject);
  private
    // CancellationToken source for the parallel loop
    FParallelCancellationTokenSource: TCancellationTokenSource;
    // Reference to the main parallel task
    FParallelCalculationTask: ITask;
    // Prime number count (protected by TInterlocked)
    FPrimeCount: Integer;
    procedure CancelParallelForProcessing;
    procedure FinalizeParallelTask;
    function InitializeCancellationToken: ICancellationToken;
    procedure SetButtonStates(RunningState: TRunningState; IsParallel: Boolean = False);
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  System.SyncObjs, System.SysUtils, System.Diagnostics, System.Variants;

type
  // Alias to simplify the code
  TLoopState = TParallel.TLoopState;

const
  // Upper limit for the prime number search
  MAX_NUMBER = 10000000;

// Helper function to check if a number is prime
function IsPrime(N: Integer): Boolean;
var
  I: Integer;
begin
  if N <= 1 then
    Result := False
  else if N <= 3 then
    Result := True
  else if (N mod 2 = 0) or (N mod 3 = 0) then
    Result := False
  else
  begin
    I := 5;
    Result := True;
    while I * I <= N do
    begin
      if (N mod I = 0) or (N mod (I + 2) = 0) then
      begin
        Result := False;
        Break;
      end;
      I := I + 6;
    end;
  end;
end;

{ TMainForm }

procedure TMainForm.FormCreate(Sender: TObject);
begin
  RegisterLogger(LogMemo.Lines);
  LogWrite('Application started.');
  SetButtonStates(IsStopped);
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  FinalizeParallelTask;
  UnregisterLogger;
end;

procedure TMainForm.CalculatePrimesSequentiallyButtonClick(Sender: TObject);
var
  i: Integer;
  PrimeCount: Integer;
  Stopwatch: TStopwatch;
begin
  LogWrite('> Starting SEQUENTIAL prime calculation up to %d...', [MAX_NUMBER]);
  LogWrite('UI is NOT responsive during SEQUENTIAL calculation.');
  SetButtonStates(IsRunning);

  Stopwatch := TStopwatch.StartNew;
  PrimeCount := 0;
  for i := 1 to MAX_NUMBER do
  begin
    if IsPrime(i) then
      Inc(PrimeCount);
  end;
  Stopwatch.Stop;

  LogWrite('SEQUENTIAL calculation finished. Primes found: %d. Time: %s ms.',
    [PrimeCount, Stopwatch.ElapsedMilliseconds.ToString]);

  SetButtonStates(IsStopped);
end;

procedure TMainForm.CalculatePrimesInParallelButtonClick(Sender: TObject);
var
  LoopResult: TParallel.TLoopResult;
  StopAfter: Boolean;
  StopAfterValue: Integer;
  Stopwatch: TStopwatch;
  Token: ICancellationToken;
begin
  LogWrite('> Starting PARALLEL prime calculation up to %d...', [MAX_NUMBER]);
  // Prepares the environment for the new calculation
  SetButtonStates(IsRunning, True);
  Token := InitializeCancellationToken;
  StopAfter := StopAfterCheckBox.Checked;
  StopAfterValue := StopAfterSpinEdit.Value;
  Stopwatch := TStopwatch.StartNew;
  // Resets the prime counter
  FPrimeCount := 0;
  // Uses TParallel.For to parallelize the loop
  // The main task encapsulates TParallel.For and its lifecycle
  FParallelCalculationTask := TTask.Run(
    // This method will be the main task that encapsulates TParallel.For
    procedure
    begin
      try
        LoopResult := TParallel.For(1, MAX_NUMBER,
          // Index is the current number in the loop
          procedure(Index: Integer; LoopState: TLoopState)
          begin
            if LoopState.ShouldExit then
              Exit;
            // Uses the captured Token to check if cancellation was
            // requested by Token: "Stop Calculation" button
            if Token.IsCancellationRequested then
            begin
              LogWrite('Parallel: Iteration %d CANCELED by Token.', [Index]);
              // Use Stop for a more immediate interruption,
              // since it was an external cancellation.
              LoopState.Stop;
              // Exits the current iteration
              Exit;
            end;
            // Optional: Stop after finding X number of primes
            // Example: stop after N primes
            if StopAfter and (MainForm.FPrimeCount > StopAfterValue) and
               (not LoopState.Stopped) and (not LoopState.Faulted) then
            begin
              LogWrite(
                'Parallel: Iteration %d BROKEN by internal condition (%d primes)!',
                [Index, MainForm.FPrimeCount]);
              // Use Break, which is "gentler".
              // Iterations already in progress can finish.
              LoopState.Break;
              // Exits the current iteration
              Exit;
            end;

            if IsPrime(Index) then
            begin
              // Access to FPrimeCount must be synchronized!
              // We use TInterlocked.Increment, which is an atomic operation and
              // much more efficient than a Critical Section for this case.
              // (We will learn all the details of TInterlocked in Topic 7.2).
              TInterlocked.Increment(FPrimeCount);
            end;
          end // End of the parallel loop body
        ); // End of TParallel.For
      finally
        Stopwatch.Stop;
        // This block is executed on the pool thread,
        // so the UI must be updated via Queue.
        TThread.Queue(nil,
          procedure
          begin
            // Checks if the form is closing (to avoid AV on shutdown)
            if csDestroying in ComponentState then
              Exit;
            LogWrite('PARALLEL calculation finished. Primes found: %d. Time: %s ms.',
              [FPrimeCount, Stopwatch.ElapsedMilliseconds.ToString]);
            // Check the status of LoopResult for additional information
            if LoopResult.Completed then
              LogWrite('LoopResult.Completed = True')
            // Check if there was an interruption via Break
            else
            if not VarIsNull(LoopResult.LowestBreakIteration) then
              LogWrite('Loop broken internally at iteration: %d',
                [Integer(LoopResult.LowestBreakIteration)])
            else
            // Task status is the source of truth for Canceled/Exception
            if FParallelCalculationTask.Status = TTaskStatus.Canceled then
              LogWrite('PARALLEL calculation CANCELED. Status: TTaskStatus.Canceled')
            else
            if FParallelCalculationTask.Status = TTaskStatus.Exception then
              LogWrite('PARALLEL calculation FAILED. Status: TTaskStatus.Exception');
            // Re-enables the buttons and disables the stop button
            SetButtonStates(IsStopped);
            // Clears the reference to the main task after it finishes and is released.
            // ITask is an Interface with automatic memory management via
            // reference counting (ARC), but keeping the reference in the field prevents
            // it from being released if the MainForm goes out of scope first.
            FParallelCalculationTask := nil;
          end);
      end;
    end);
  LogWrite('TParallel.For task launched! UI remains responsive.');
  CheckTasksFirstRun(True);
end;

procedure TMainForm.StopParallelCalculationButtonClick(Sender: TObject);
begin
  LogWrite('* Requesting CANCELLATION of the parallel calculation...');
  SetButtonStates(IsStopped);
  // Signals the cancellation
  CancelParallelForProcessing;
end;

procedure TMainForm.SetButtonStates(RunningState: TRunningState; IsParallel: Boolean = False);
begin
  if csDestroying in ComponentState then
    Exit;
  CalculatePrimesSequentiallyButton.Enabled := RunningState = IsStopped;
  CalculatePrimesInParallelButton.Enabled := RunningState = IsStopped;
  StopParallelCalculationButton.Enabled := (RunningState = IsRunning) and IsParallel;
  StopAfterCheckBox.Enabled := RunningState = IsStopped;
  StopAfterSpinEdit.Enabled := RunningState = IsStopped;

  if IsParallel then
  begin
    StopParallelCalculationButton.SetFocus;
  end;
  Repaint;
end;

procedure TMainForm.CancelParallelForProcessing;
begin
  // Frees the CancellationToken source after the task completes
  if Assigned(FParallelCancellationTokenSource) then
  begin
    FParallelCancellationTokenSource.Cancel;
  end;
end;

function TMainForm.InitializeCancellationToken: ICancellationToken;
begin
  if Assigned(FParallelCancellationTokenSource) then
    // If CancellationToken already exists, it is reset
    FParallelCancellationTokenSource.Reset
  else
    // Creates the CancellationToken source for this new execution
    FParallelCancellationTokenSource := TCancellationTokenSource.Create;
  Result := FParallelCancellationTokenSource.Token;
end;

procedure TMainForm.FinalizeParallelTask;
begin
  // Ensures the parallel task is terminated and freed when closing the form
  if Assigned(FParallelCalculationTask) then
  begin
    // Signals cancellation
    CancelParallelForProcessing;
    // Waits for the task to finish (blocks, but is necessary for cleanup)
    FParallelCalculationTask.Wait;
    FParallelCalculationTask := nil;
  end;
  // Frees the CancellationToken source if it hasn't been freed yet
  if Assigned(FParallelCancellationTokenSource) then
  begin
    FParallelCancellationTokenSource.Free;
    FParallelCancellationTokenSource := nil;
  end;
end;

end.