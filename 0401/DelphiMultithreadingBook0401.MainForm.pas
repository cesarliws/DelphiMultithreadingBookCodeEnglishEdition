unit DelphiMultithreadingBook0401.MainForm;

interface

uses
  System.Classes, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  DelphiMultithreadingBook0401.PausableWorkerThread,
  DelphiMultithreadingBook.Utils;

type
  TMainForm = class(TForm)
    StartThreadButton: TButton;
    LogMemo: TMemo;
    PauseThreadButton: TButton;
    ResumeThreadButton: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure StartThreadButtonClick(Sender: TObject);
    procedure PauseThreadButtonClick(Sender: TObject);
    procedure ResumeThreadButtonClick(Sender: TObject);
  private
    FPausableThread: TPausableWorkerThread;
    procedure FinalizeThread;
    procedure PausableThreadTerminated(Sender: TObject);
    procedure SetButtonStates(RunningState: TRunningState);
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  DelphiMultithreadingBook0401.SharedData;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  RegisterLogger(LogMemo.Lines);
  LogWrite('Application started. Click the button to start the thread.');
  SetButtonStates(IsStopped);
  LogMemo.ScrollBars := ssVertical;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  UnregisterLogger;
  FinalizeThread;
end;

procedure TMainForm.StartThreadButtonClick(Sender: TObject);
begin
  SetButtonStates(IsRunning);
  FinalizeThread;
  LogWrite('> Starting Pausable Thread...');
  // Ensure the event starts in a signaled state (not paused)
  PauseEvent.SetEvent;
  FPausableThread := TPausableWorkerThread.Create(1, LogWrite);
  FPausableThread.OnTerminate := PausableThreadTerminated;
end;

procedure TMainForm.PauseThreadButtonClick(Sender: TObject);
begin
  if Assigned(FPausableThread) then
  begin
    SetButtonStates(IsPaused);
    LogWrite('Requesting PAUSE of the thread...');
    // Puts the event in a non-signaled state
    PauseEvent.ResetEvent;
  end;
end;

procedure TMainForm.ResumeThreadButtonClick(Sender: TObject);
begin
  if Assigned(FPausableThread) then
  begin
    SetButtonStates(IsRunning);
    LogWrite('Requesting RESUME of the thread...');
    // Puts the event in a signaled state
    PauseEvent.SetEvent;
  end;
end;

procedure TMainForm.FinalizeThread;
begin
  if Assigned(FPausableThread) then
  begin
    // TerminatedSet is invoked, signaling the event to ensure the thread
    // exits its wait state (WaitFor) if it's paused, allowing it to terminate.
    FPausableThread.Terminate;
    // Wait for the thread to finish before destroying it
    FPausableThread.WaitFor;
    FPausableThread.Free;
    FPausableThread := nil;
  end;
end;

procedure TMainForm.PausableThreadTerminated(Sender: TObject);
begin
  LogWrite('Pausable Thread processing completed.');
  SetButtonStates(IsStopped);
end;

procedure TMainForm.SetButtonStates(RunningState: TRunningState);
begin
  StartThreadButton.Enabled := RunningState = IsStopped;
  PauseThreadButton.Enabled := RunningState = IsRunning;
  ResumeThreadButton.Enabled := RunningState = IsPaused;
end;

end.
