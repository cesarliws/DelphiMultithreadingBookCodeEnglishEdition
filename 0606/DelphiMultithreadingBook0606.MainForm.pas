unit DelphiMultithreadingBook0606.MainForm;

interface

uses
  System.Classes, System.SysUtils, System.Threading, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls,
  DelphiMultithreadingBook.Utils;

type
  TMainForm = class(TForm)
    SortArraySequentialButton: TButton;
    SortArrayParallelButton: TButton;
    ProcessArraySequentialButton: TButton;
    ProcessArrayParallelButton: TButton;
    LogMemo: TMemo;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure SortArraySequentialButtonClick(Sender: TObject);
    procedure SortArrayParallelButtonClick(Sender: TObject);
    procedure ProcessArraySequentialButtonClick(Sender: TObject);
    procedure ProcessArrayParallelButtonClick(Sender: TObject);
  private
    // Array for sorting
    FBigIntegerArray: TArray<Integer>;
    // Array for processing
    FBigStringArray: array of string;
    // TArray<string> does not work, bug! passes wrong values in AValues
    // FBigStringArray: TArray<string>;
    FBenchmarkTask: ITask;
    function CopyBigIntegerArray: TArray<Integer>;
    procedure PopulateBigIntegerArray(Size: Integer);
    procedure PopulateBigStringArray(Size: Integer);
    procedure RunBenchmark(const BenchmarkName: string; BenchmarkProc: TProc);
    procedure SetButtonStates(RunningState: TRunningState);
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  System.Diagnostics, // TStopwatch;
  System.Generics.Collections, // TArray.Sort<T>
  System.SyncObjs; // TParallelArray

const
  // 10 million for integers
  INTEGER_ARRAY_SIZE = 10000000;
  // 10 million for strings
  STRING_ARRAY_SIZE = 10000000;

// Auxiliary function to count occurrences of a character in the string
function CountCharInString(const S: string; CharToCount: Char): Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 1 to Length(S) do
    if S[i] = CharToCount then
      Inc(Result);
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  RegisterLogger(LogMemo.Lines);
  LogWrite('Application started.');

  PopulateBigIntegerArray(INTEGER_ARRAY_SIZE);
  LogWrite('Integer Array populated with %d items.', [Length(FBigIntegerArray)]);

  PopulateBigStringArray(STRING_ARRAY_SIZE);
  LogWrite('String Array populated with %d items.', [Length(FBigStringArray)]);
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := not Assigned(FBenchmarkTask);
  if not CanClose then
  begin
    LogWrite('* Wait for the processing to finish before closing this Window!')
  end;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  UnregisterLogger;
end;

procedure TMainForm.PopulateBigIntegerArray(Size: Integer);
var
  i: Integer;
begin
  SetLength(FBigIntegerArray, Size);
  Randomize;
  for i := 0 to High(FBigIntegerArray) do
    // Populates with random numbers
    FBigIntegerArray[i] := Random(Size);
end;

procedure TMainForm.PopulateBigStringArray(Size: Integer);
var
  i, j: Integer;
  S: string;
begin
  SetLength(FBigStringArray, Size);
  Randomize;
  for i := 0 to High(FBigStringArray) do
  begin
    // Generates simple random strings for the example
    // Strings from 5 to 24 characters
    SetLength(S, Random(20) + 5);
    for j := 1 to Length(S) do
      // Uppercase letters A-Z
      S[j] := Chr(65 + Random(26));

    FBigStringArray[i] := S;
  end;
end;

procedure TMainForm.SortArraySequentialButtonClick(Sender: TObject);
var
  TempArray: TArray<Integer>;
begin
  // Creates a copy so as not to affect the original array
  TempArray := CopyBigIntegerArray;
  RunBenchmark('SEQUENTIAL Sorting',
    procedure
    begin
      // Sequential sorting (from the RTL)
      TArray.Sort<Integer>(TempArray);
    end);
end;

procedure TMainForm.SortArrayParallelButtonClick(Sender: TObject);
var
  TempArray: TArray<Integer>;
begin
  // Creates a copy so as not to affect the original array
  TempArray := CopyBigIntegerArray;
  RunBenchmark('PARALLEL Sorting (TParallelArray.Sort)',
    procedure
    begin
      CheckTasksFirstRun(True);
      // Parallel sorting (from the PPL)
      TParallelArray.Sort<Integer>(TempArray);
    end);
end;

procedure TMainForm.ProcessArraySequentialButtonClick(Sender: TObject);
var
  TotalAChars: Integer; // Move the variable outside to be captured
begin
  RunBenchmark('SEQUENTIAL string Processing',
    procedure
    var
      CurrentString: string;
      i: Integer;
    begin
      TotalAChars := 0;
      for i := 0 to High(FBigStringArray) do
      begin
        CurrentString := UpperCase(FBigStringArray[i]);
        Inc(TotalAChars, CountCharInString(CurrentString, 'A'));
      end;
      LogWrite('Total "A"s found: %d', [TotalAChars]);
    end);
end;

procedure TMainForm.ProcessArrayParallelButtonClick(Sender: TObject);
var
  TotalAChars: Integer; // Move the variable outside to be captured
begin
  RunBenchmark('PARALLEL string Processing (TParallelArray.For)',
    procedure
    begin
      CheckTasksFirstRun(True);
      TotalAChars := 0;
      TParallelArray.For<string>(FBigStringArray,
        procedure(const Values: array of string; First, Last: NativeInt)
        var
          i: NativeInt;
          CurrentString: string;
          CountA: Integer;
        begin
          for i := First to Last do
          begin
            CurrentString := UpperCase(Values[i]);
            CountA := CountCharInString(CurrentString, 'A');
            TInterlocked.Add(TotalAChars, CountA);
          end;
        end);
      LogWrite('Total "A"s found: %d', [TotalAChars]);
    end);
end;

procedure TMainForm.RunBenchmark(const BenchmarkName: string;
  BenchmarkProc: TProc);
begin
  if Assigned(FBenchmarkTask) then
  begin
    LogWrite('Wait for the previous benchmark to finish.');
    Exit;
  end;

  LogWrite('-----------------------------------------------------');
  LogWrite('> Starting benchmark: %s...', [BenchmarkName]);
  SetButtonStates(IsRunning);
  // Forces the UI to update before starting the task
  Repaint;

  FBenchmarkTask := TTask.Run(
    procedure
    var
      Stopwatch: TStopwatch;
    begin
      Stopwatch := TStopwatch.StartNew;
      try
        // Executes the benchmark (sequential or parallel) in background
        BenchmarkProc;
      finally
        Stopwatch.Stop;
        // Queues the result for the UI
        TThread.Queue(nil,
          procedure
          begin
            LogWrite('%s completed. Time: %d ms.',
              [BenchmarkName, Stopwatch.ElapsedMilliseconds]);
            SetButtonStates(IsStopped);
            // Releases the reference for the next test
            FBenchmarkTask := nil;
            Repaint;
          end);
      end;
    end);
end;

function TMainForm.CopyBigIntegerArray: TArray<Integer>;
begin
  SetLength(Result, Length(FBigIntegerArray));
  TArray.Copy<Integer>(FBigIntegerArray, Result, Length(FBigIntegerArray));
end;

procedure TMainForm.SetButtonStates(RunningState: TRunningState);
begin
  SortArraySequentialButton.Enabled := RunningState = IsStopped;
  SortArrayParallelButton.Enabled := RunningState = IsStopped;
  ProcessArraySequentialButton.Enabled := RunningState = IsStopped;
  ProcessArrayParallelButton.Enabled := RunningState = IsStopped;
  Repaint;
end;

end.
