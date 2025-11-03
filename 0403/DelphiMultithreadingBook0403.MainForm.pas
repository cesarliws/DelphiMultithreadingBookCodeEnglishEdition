unit DelphiMultithreadingBook0403.MainForm;

interface

uses
  System.Classes, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls,
  DelphiMultithreadingBook0403.PausableWorkerThread,
  DelphiMultithreadingBook.CancellationToken,
  DelphiMultithreadingBook.Utils;

type
  TMainForm = class(TForm)
    StartThreadButton: TButton;
    StopThreadButton: TButton;
    PauseThreadButton: TButton;
    ResumeThreadButton: TButton;
    LogMemo: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure StartThreadButtonClick(Sender: TObject);
    procedure StopThreadButtonClick(Sender: TObject);
    procedure PauseThreadButtonClick(Sender: TObject);
    procedure ResumeThreadButtonClick(Sender: TObject);
  private
    // The source of the cancellation token
    FCancellationTokenSource: TCancellationTokenSource;
    FPausableThread: TPausableWorkerThread;
    procedure PausableThreadTerminated(Sender: TObject);
    procedure SetButtonStates(RunningState: TRunningState);
    procedure CreateThread;
    procedure FinalizeThread;
    procedure InitializeTokenSource;
    procedure StopThread;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  DelphiMultithreadingBook0403.SharedData;

procedure TMainForm.CreateThread;
begin
  // Finalize any previous thread instance
  FinalizeThread;
  // Pass the token to the thread
  FPausableThread := TPausableWorkerThread.Create(1, FCancellationTokenSource.Token);
  FPausableThread.OnTerminate := PausableThreadTerminated;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  RegisterLogger(LogMemo.Lines);
  LogWrite('Application started. Click the button to start the thread.');
  SetButtonStates(IsStopped);
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  // StopThread will send the cancellation signal to the thread(s) and wait for
  // its cooperative termination before destroying the thread instance.
  StopThread;
  // Free the cancellation token source
  if Assigned(FCancellationTokenSource) then
  begin
    // WARNING: The token source should only be destroyed after the threads
    // that use its token have terminated.
    FCancellationTokenSource.Free;
  end;
  UnregisterLogger;
end;

procedure TMainForm.StopThread;
begin
  // Gracefully terminate the pausable thread
  if Assigned(FPausableThread) then
  begin
    // If the thread is still running, request cancellation
    if Assigned(FCancellationTokenSource) then
    begin
      // STEP 1: Request cancellation
      FCancellationTokenSource.Cancel;
      // Ensure the thread exits WaitFor if it is paused
      PauseEvent.SetEvent;
    end;
    // STEP 2: Wait for the worker thread to actually finish its execution
    // This is important so the MainThread does not try to access the thread
    // while it is terminating.
    FPausableThread.WaitFor;
    FinalizeThread;
  end;
end;

procedure TMainForm.FinalizeThread;
begin
  if Assigned(FPausableThread) then
  begin
    // If the thread finished all steps normally, clear the reference
    FPausableThread.Free;
    FPausableThread := nil;
  end;
end;

procedure TMainForm.InitializeTokenSource;
begin
  if not Assigned(FCancellationTokenSource) then
    // Create the cancellation token source
    FCancellationTokenSource := TCancellationTokenSource.Create
  else
    // If the source already exists, reset it
    FCancellationTokenSource.Reset;
end;

procedure TMainForm.SetButtonStates(RunningState: TRunningState);
begin
  if csDestroying in ComponentState then
    Exit;
  StartThreadButton.Enabled := RunningState = IsStopped;
  PauseThreadButton.Enabled := RunningState = IsRunning;
  ResumeThreadButton.Enabled := RunningState = IsPaused;
  StopThreadButton.Enabled := RunningState in [IsRunning, IsPaused];
  if not Visible then
    Exit;
  case RunningState of
    IsRunning: PauseThreadButton.SetFocus;
    IsPaused: ResumeThreadButton.SetFocus;
    IsStopped: StartThreadButton.SetFocus;
  end;
end;

procedure TMainForm.PausableThreadTerminated(Sender: TObject);
begin
  SetButtonStates(IsStopped);
end;

procedure TMainForm.StartThreadButtonClick(Sender: TObject);
begin
  SetButtonStates(IsRunning);
  LogWrite('> Starting Pausable Thread (with CancellationToken)...');
  StopThread;
  InitializeTokenSource;
  CreateThread;
end;

procedure TMainForm.StopThreadButtonClick(Sender: TObject);
begin
  if Assigned(FPausableThread) then
  begin
    LogWrite('Requesting STOP of Pausable Thread (with CancellationToken)...');
    StopThread;
    LogWrite('Pausable Thread terminated.');
  end;
end;

procedure TMainForm.PauseThreadButtonClick(Sender: TObject);
begin
  if Assigned(FPausableThread) then
  begin
    LogWrite('Requesting PAUSE of the Thread...');
    PauseEvent.ResetEvent;
    SetButtonStates(IsPaused);
  end;
end;

procedure TMainForm.ResumeThreadButtonClick(Sender: TObject);
begin
  if Assigned(FPausableThread) then
  begin
    LogWrite('Requesting RESUME of the Thread...');
    PauseEvent.SetEvent;
    SetButtonStates(IsRunning);
  end;
end;

end.
