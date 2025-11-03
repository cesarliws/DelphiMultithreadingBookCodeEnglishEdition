unit DelphiMultithreadingBook0801.MainForm;

interface

uses
  System.Classes, Vcl.ComCtrls, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls,
  // Imports the worker thread and worker processor for type access
  DelphiMultithreadingBook0801.WorkerThread, DelphiMultithreadingBook0801.WorkerProcessor,
  DelphiMultithreadingBook.Utils;

type
  TMainForm = class(TForm)
    StartCalculationButton: TButton;
    CancelCalculationButton: TButton;
    ProgressBar: TProgressBar;
    LogMemo: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure StartCalculationButtonClick(Sender: TObject);
    procedure CancelCalculationButtonClick(Sender: TObject);
  private
    // Our worker thread instance
    FWorkerThread: TWorkerThread;
    // Callbacks to be passed to the WorkerProcessor
    procedure UpdateProgress(const Text: string; Progress: Integer);
    procedure ReportThreadError(const Text: string);
    // Thread OnTerminate handler
    procedure WorkerThreadTerminate(Sender: TObject);
    // Controls button state
    procedure SetButtonStates(RunningState: TRunningState);
    procedure FinalizeThread;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  System.SysUtils, Vcl.Dialogs;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  RegisterLogger(LogMemo.Lines);
  LogWrite('Application started.');
  // Initial state: nothing running
  SetButtonStates(IsStopped);
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  FinalizeThread;
  UnregisterLogger;
end;

procedure TMainForm.SetButtonStates(RunningState: TRunningState);
begin
  StartCalculationButton.Enabled := RunningState = IsStopped;
  CancelCalculationButton.Enabled := RunningState = IsRunning;
end;

procedure TMainForm.FinalizeThread;
begin
  // Ensures the thread is terminated and freed when closing the form
  if Assigned(FWorkerThread) then
  begin
    FWorkerThread.RequestCancel;
    // Requests cancellation
    FWorkerThread.WaitFor;
    // Waits for the thread to terminate
    FWorkerThread.Free;
    // Frees the thread object
    FWorkerThread := nil;
  end;
end;

procedure TMainForm.UpdateProgress(const Text: string; Progress: Integer);
var
  Cancelled: Boolean;
begin
  Cancelled := Assigned(FWorkerThread) and FWorkerThread.Processor.CancelRequested
    and not Text.Contains('Progress');

  if not Cancelled then
  begin
    LogWrite('[%d%%] %s', [Progress, Text]);
    ProgressBar.Position := Progress;
  end
  else
    LogWrite('%s', [Text]);
end;

procedure TMainForm.ReportThreadError(const Text: string);
begin
  LogWrite('ERROR REPORTED: %s', [Text]);
  // Example of error notification
  ShowMessage(Text);
end;

procedure TMainForm.WorkerThreadTerminate(Sender: TObject);
var
  WorkerThread: TWorkerThread;
begin
  // This event is executed on the main thread (UI Thread)!
  WorkerThread := Sender as TWorkerThread;
  LogWrite('Calculation finalized on Thread (ID: %d).', [WorkerThread.ThreadID]);
  // Re-enables buttons to start a new calculation
  SetButtonStates(IsStopped);
end;


procedure TMainForm.StartCalculationButtonClick(Sender: TObject);
var
  Processor: TWorkerProcessor;
begin
  // Ensures any previous thread is finalized and cleaned up
  FinalizeThread;
  LogWrite('> Starting calculation on worker thread...');
  // Disables start, enables cancel
  SetButtonStates(IsRunning);
  ProgressBar.Max := 100;
  ProgressBar.Position := 0;
  // 1. Creates the Processor instance and configures its callbacks
  Processor := TWorkerProcessor.Create(UpdateProgress, ReportThreadError);
  // 2. Creates the WorkerThread, passing the Processor instance
  FWorkerThread := TWorkerThread.Create(Processor);
  // Associates the termination handler
  FWorkerThread.OnTerminate := WorkerThreadTerminate;
  // Starts the thread
  FWorkerThread.Start;
end;

procedure TMainForm.CancelCalculationButtonClick(Sender: TObject);
begin
  if Assigned(FWorkerThread) and (not FWorkerThread.Finished) then
  begin
    LogWrite('Requesting calculation cancellation...');
    // Signals cancellation to the thread
    FWorkerThread.RequestCancel;
    // WorkerThreadTerminate will take care of re-enabling the buttons after the thread finishes
  end;
end;

end.
