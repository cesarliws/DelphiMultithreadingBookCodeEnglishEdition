unit DelphiMultithreadingBook0201.MainForm;

interface

uses
  System.Classes, Vcl.Controls, Vcl.ComCtrls, Vcl.Forms, Vcl.StdCtrls,
  DelphiMultithreadingBook0201.WorkerThread, DelphiMultithreadingBook.Utils;

type
  TMainForm = class(TForm)
    StartThreadButton: TButton;
    StopThreadButton: TButton;
    ProgressBar: TProgressBar;
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
  LogWrite('Application started, click "Start Thread".');
  ProgressBar.Min := 0;
  ProgressBar.Max := 100;
  ProgressBar.Position := 0;
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
  FinalizeThread;
  LogWrite('> Starting worker thread...');
  LogWrite('The interface remains responsive.');
  ProgressBar.Position := 0;
  // We create an instance of our thread
  FWorkerThread := TWorkerThread.Create(ProgressBar);
  FWorkerThread.OnTerminate := WorkerThreadTerminated;
  // Start the thread
  FWorkerThread.Start;
  SetButtonStates(IsRunning);
end;

procedure TMainForm.StopThreadButtonClick(Sender: TObject);
begin
  if Assigned(FWorkerThread) then
  begin
    LogWrite('Requesting thread termination...');
    FinalizeThread;
    LogWrite('Thread terminated and freed.');
    SetButtonStates(IsStopped);
  end;
end;

procedure TMainForm.FinalizeThread;
begin
  if Assigned(FWorkerThread) then
  begin
    // Signal to terminate
    FWorkerThread.Terminate;
    // Wait for the thread to actually finish
    FWorkerThread.WaitFor;
    // Free the thread object
    FWorkerThread.Free;
    // Remove the reference to the freed instance
    FWorkerThread := nil;
  end;
end;

procedure TMainForm.SetButtonStates(RunningState: TRunningState);
begin
  StartThreadButton.Enabled := RunningState = IsStopped;
  StopThreadButton.Enabled := RunningState = IsRunning;
end;

procedure TMainForm.WorkerThreadTerminated(Sender: TObject);
begin
  SetButtonStates(IsStopped);
end;

end.
