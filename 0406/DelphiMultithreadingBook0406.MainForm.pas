unit DelphiMultithreadingBook0406.MainForm;

interface

uses
  System.Classes, System.SysUtils, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls,
  DelphiMultithreadingBook0406.WorkerWithRetryOnErrorThread;

type
  TMainForm = class(TForm)
    StartThreadWithRetryButton: TButton;
    RunUntilFailureCheckBox: TCheckBox;
    LogMemo: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure StartThreadWithRetryButtonClick(Sender: TObject);
  private
    FWorkerWithRetryOnErrorThread: TWorkerWithRetryOnErrorThread;
    procedure FinalizeThread;
    procedure WorkerThreadTerminate(Sender: TObject);
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  System.Threading, WinApi.Messages, WinApi.Windows,
  DelphiMultithreadingBook.ExceptionUtils, DelphiMultithreadingBook.Utils;

procedure TMainForm.FinalizeThread;
begin
  if Assigned(FWorkerWithRetryOnErrorThread) then
  begin
    FWorkerWithRetryOnErrorThread.OnTerminate := nil;
    FWorkerWithRetryOnErrorThread.Terminate;
    FWorkerWithRetryOnErrorThread.WaitFor;
    FWorkerWithRetryOnErrorThread.Free;
  end;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  RegisterLogger(LogMemo.Lines);
  LogMemo.ScrollBars := ssVertical;
  RunUntilFailureCheckBox.Checked := True;
  LogWrite('Application started.');
  LogWrite('Click "Start Thread with Retry" to test the reprocessing.');
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  UnregisterLogger;
  FinalizeThread;
end;

procedure TMainForm.StartThreadWithRetryButtonClick(Sender: TObject);
const
  MAX_RETRIES = 3;
  INITIAL_DELAY_MS = 500;
begin
  FinalizeThread;
  LogWrite('> Starting Thread with Reprocessing and Retry...');
  FWorkerWithRetryOnErrorThread := TWorkerWithRetryOnErrorThread.Create(
    MAX_RETRIES, INITIAL_DELAY_MS);
  FWorkerWithRetryOnErrorThread.OnTerminate := WorkerThreadTerminate;
end;

procedure TMainForm.WorkerThreadTerminate(Sender: TObject);
var
  RunAgain: Boolean;
  WorkerThread: TWorkerWithRetryOnErrorThread;
begin
  // This method is executed in the main thread (UI thread)
  WorkerThread := Sender as TWorkerWithRetryOnErrorThread;
  RunAgain := False;
  LogWrite('Thread %d TERMINATED.', [WorkerThread.ThreadID]);
  // Checks if the thread has collected any errors
  if Assigned(WorkerThread.Error) then
  begin
    // Uses the HandlePotentialAggregateException procedure to display the error
    // (which could be an EAggregateException) in the Events Window
    HandlePotentialAggregateException(WorkerThread.Error);
    LogWrite('--- Aggregate Exception caught! ---');
    LogWrite('Total failures recorded: %d', [WorkerThread.Error.Count]);
    LogWrite('----------------------------------------');
    LogWrite('');
  end
  else
  begin
    LogWrite('Thread completed with no reported errors.');
    RunAgain := RunUntilFailureCheckBox.Checked
      and not (csDestroying in ComponentState);
  end;
  if RunAgain then
  begin
    TThread.ForceQueue(nil,
      procedure
      begin
        if (csDestroying in ComponentState) then
          Exit;
        LogWrite('');
        LogWrite('Running again...');
        StartThreadWithRetryButton.Click;
        SendMessage(LogMemo.Handle, EM_LINESCROLL, 0,LogMemo.Lines.Count);
      end);
  end;
end;

end.
