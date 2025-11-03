unit DelphiMultithreadingBook0404.MainForm;

interface

uses
  System.Classes, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Vcl.ExtCtrls,
  DelphiMultithreadingBook.Utils;

type
  TMainForm = class(TForm)
    StartThreadsButton: TButton;
    LogMemo: TMemo;
    TestTimer: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure StartThreadsButtonClick(Sender: TObject);
    procedure TestTimerTimer(Sender: TObject);
  private
    FThreadTimeCritical: TThread;
    FThreadIdle: TThread;
    procedure FinalizeThreads;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  System.SysUtils, DelphiMultithreadingBook0404.PriorityWorker;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  RegisterLogger(LogMemo.Lines);
  LogWrite('Application started.');
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  FinalizeThreads;
  UnregisterLogger;
end;

procedure TMainForm.FinalizeThreads;
begin
  TestTimer.Enabled := False;
  // Terminate signals the threads to stop. Since FreeOnTerminate is true,
  // we don't need to WaitFor/Free them. We just nil the references.
  if Assigned(FThreadTimeCritical) then
  begin
    FThreadTimeCritical.Terminate;
    FThreadTimeCritical := nil;
  end;
  if Assigned(FThreadIdle) then
  begin
    FThreadIdle.Terminate;
    FThreadIdle := nil;
  end;
end;

procedure TMainForm.StartThreadsButtonClick(Sender: TObject);
begin
  FinalizeThreads;
  LogMemo.Lines.Clear;
  LogWrite('> Starting threads with TIME CRITICAL and IDLE priorities...');
  StartThreadsButton.Enabled := False;
  // Create the two threads with opposite priorities
  FThreadTimeCritical := TPriorityWorker.Create('TIME CRITICAL Thread', tpTimeCritical);
  FThreadIdle := TPriorityWorker.Create('IDLE Thread', tpIdle);
  // Use a TTimer to end the test after 5 seconds
  TestTimer.Enabled := True;
  LogWrite('TIME CRITICAL and IDLE threads started, please wait...');
end;

procedure TMainForm.TestTimerTimer(Sender: TObject);
begin
  // Fires only once
  TestTimer.Enabled := False;
  LogWrite('--- End of Test ---');
  FinalizeThreads;
  StartThreadsButton.Enabled := True;
end;

end.
