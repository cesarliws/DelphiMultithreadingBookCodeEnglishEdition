unit DelphiMultithreadingBook0306.MainForm;

interface

uses
  System.Classes, System.UITypes, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls,
  DelphiMultithreadingBook0306.Workers, DelphiMultithreadingBook.Utils;

type
  TMainForm = class(TForm)
    StartCriticalSectionButton: TButton;
    StartMREWButton: TButton;
    LogMemo: TMemo;
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure StartCriticalSectionButtonClick(Sender: TObject);
    procedure StartMREWButtonClick(Sender: TObject);
  private
    procedure RunTest(LockType: TLockType);
    procedure SetButtonsState(RunningState: TRunningState);
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  System.Diagnostics, System.SyncObjs, System.SysUtils;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  RegisterLogger(LogMemo.Lines);
  LogWrite('Application Started.');
  LogWrite('Run the tests a few times to compare the results.');
  LogMemo.ScrollBars := ssVertical;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  UnregisterLogger;
end;

procedure TMainForm.RunTest(LockType: TLockType);
const
  READER_COUNT = 8;
  START_MESSAGE = '> Starting test with %s (%d threads)...';
var
  ConfigList: TStringList;
  Countdown: TCountdownEvent;
  CriticalSection: TCriticalSection;
  i: Integer;
  MREW: TLightweightMREW;
  Stopwatch: TStopwatch;
begin
  if LockType = TLockType.MultiReadExclusiveWrite then
    LogWrite(START_MESSAGE, ['TLightweightMREW', READER_COUNT])
  else
    LogWrite(START_MESSAGE, ['TCriticalSection', READER_COUNT]);

  SetButtonsState(IsRunning);
  ConfigList := TStringList.Create;
  CriticalSection := TCriticalSection.Create;
  Countdown := TCountdownEvent.Create(READER_COUNT);
  Stopwatch := TStopwatch.StartNew;
  // Fire off the reader threads
  for i := 1 to READER_COUNT do
    TReaderThread.Create(LockType, ConfigList, CriticalSection, MREW,
      procedure(const Msg: string)
      begin
        LogWrite(Msg);
        // This callback is called when each thread finishes
        Countdown.Signal;
      end);
  // Orchestrator thread to wait for the end without blocking the UI
  TThread.CreateAnonymousThread(procedure
    begin
      // Wait for all 8 threads to signal
      Countdown.WaitFor;
      Stopwatch.Stop;
      TThread.Queue(nil,
        procedure
        begin
          LogWrite('------------------------------------');
          LogWrite(Format('Test completed in: %d ms', [Stopwatch.ElapsedMilliseconds]));
          ConfigList.Free;
          CriticalSection.Free;
          Countdown.Free;
          SetButtonsState(IsStopped);
        end);
    end
  ).Start;
end;


procedure TMainForm.StartCriticalSectionButtonClick(Sender: TObject);
begin
  RunTest(TLockType.CriticalSection);
end;

procedure TMainForm.StartMREWButtonClick(Sender: TObject);
begin
  RunTest(TLockType.MultiReadExclusiveWrite);
end;

procedure TMainForm.SetButtonsState(RunningState: TRunningState);
begin
  if csDestroying in ComponentState then
    Exit;
  StartCriticalSectionButton.Enabled := RunningState = IsStopped;
  StartMREWButton.Enabled := RunningState = IsStopped;
end;

end.
