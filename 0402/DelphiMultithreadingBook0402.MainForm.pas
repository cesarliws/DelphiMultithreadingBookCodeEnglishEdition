unit DelphiMultithreadingBook0402.MainForm;

interface

uses
  System.Classes, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls,
  DelphiMultithreadingBook0402.WorkerThread,
  DelphiMultithreadingBook.Utils;

type
  TMainForm = class(TForm)
    StartThreadButton: TButton;
    StopThreadButton: TButton;
    LogMemo: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure StartThreadButtonClick(Sender: TObject);
    procedure StopThreadButtonClick(Sender: TObject);
  private
    FWorkerThread: TWorkerThread;
    procedure FinalizeThread;
    procedure SetButtonStates(RunningState: TRunningState);
    procedure WorkerThreadTerminated(Sender: TObject);
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

procedure TMainForm.FormCreate(Sender: TObject);
begin
  RegisterLogger(LogMemo.Lines);
  LogWrite('Application started. Click "Start Thread" to begin.');
  SetButtonStates(IsStopped);
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  // Ensures the thread is terminated and freed when closing the form
  FinalizeThread;
  UnregisterLogger;
end;

procedure TMainForm.StartThreadButtonClick(Sender: TObject);
begin
  // Finalize any previous processing instance
  FinalizeThread;
  LogWrite('> Starting worker thread (for graceful termination)...');
  // Create the thread
  FWorkerThread := TWorkerThread.Create(1);
  FWorkerThread.OnTerminate := WorkerThreadTerminated;
  FWorkerThread.Start;
  LogWrite('Wait for processing or click "Stop Thread" to terminate...');
  SetButtonStates(IsRunning);
  StopThreadButton.SetFocus;
end;

procedure TMainForm.StopThreadButtonClick(Sender: TObject);
begin
  LogWrite('Requesting graceful termination of the thread...');
  FinalizeThread;
  LogWrite('Thread terminated and freed successfully.');
end;

procedure TMainForm.SetButtonStates(RunningState: TRunningState);
begin
  if csDestroying in ComponentState then
    Exit;
  StartThreadButton.Enabled := RunningState = IsStopped;
  StopThreadButton.Enabled := RunningState = IsRunning;
end;

procedure TMainForm.WorkerThreadTerminated(Sender: TObject);
begin
  if csDestroying in ComponentState then
    Exit;
  LogWrite('The thread has completed its work...');
  SetButtonStates(IsStopped);
  StartThreadButton.SetFocus;
end;

procedure TMainForm.FinalizeThread;
begin
  if Assigned(FWorkerThread) then
  begin
    // Signal the thread to terminate cooperatively
    FWorkerThread.Terminate;
    // Wait for the thread to actually finish
    FWorkerThread.WaitFor;
    // Free the thread object
    FWorkerThread.Free;
    // Clear the reference
    FWorkerThread := nil;
  end;
end;

end.
