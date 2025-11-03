unit DelphiMultithreadingBook1001.MainForm;

interface

uses
  System.Classes, System.Threading, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Vcl.ComCtrls,
  DelphiMultithreadingBook1001.LogFileProcessor, DelphiMultithreadingBook.Utils;

type
  TMainForm = class(TForm)
    GenerateLogFilesButton: TButton;
    ProcessFilesButton: TButton;
    CancelButton: TButton;
    ProgressBar: TProgressBar;
    LogMemo: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure GenerateLogFilesButtonClick(Sender: TObject);
    procedure ProcessFilesButtonClick(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    FCurrentTask: ITask;
    FLogProcessor: TLogFileProcessor;
    FLogsDirectory: string;
    procedure LogProgress(const ProcessedCount, TotalCount: Integer; const FileName: string);
    procedure LogCompletion(const WasCancelled: Boolean; const TotalFiles, TotalLines,
      TotalWords: Int64; const ErrorLines: TStrings);
    procedure SetButtonStates(RunningState: TRunningState);
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  System.IOUtils, System.SysUtils;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  RegisterLogger(LogMemo.Lines);
  FLogsDirectory := TPath.Combine(TPath.GetTempPath, 'BookLogs');
  LogWrite('Sample log directory: ' + FLogsDirectory);
  LogWrite('Use the "Generate Files" button to create test data.');
  SetButtonStates(IsStopped);
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := not Assigned(FCurrentTask) and not Assigned(FLogProcessor);
  if not CanClose then
  begin
    LogWrite('* Please wait for the Processing to finish before closing the Window!');
  end;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  if Assigned(FLogProcessor) then
   FLogProcessor.Cancel;
  if Assigned(FCurrentTask) then
    FCurrentTask.Cancel;
  UnregisterLogger;
end;

procedure TMainForm.GenerateLogFilesButtonClick(Sender: TObject);
const
  SERVER_ERROR = 'Timestamp: %s - Level: ERROR - Details: Failed to connect to server X.';
  OPERATION_INFO = 'Timestamp: %s - Level: INFO - Details: Operation %d completed.';
begin
  LogWrite('> Generating 20 sample log files...');
  SetButtonStates(IsRunning);
  FCurrentTask := TTask.Run(
    procedure
    var
      i, j: Integer;
      Line, LogsDirectory, TimeStamp: String;
      LogFile: TStringList;
    begin
      LogsDirectory := FLogsDirectory;
      if not TDirectory.Exists(LogsDirectory) then
        TDirectory.CreateDirectory(LogsDirectory);

      LogFile := TStringList.Create;
      try
        for i := 1 to 20 do
        begin
          LogFile.Clear;
          // 5000 lines per file
          for j := 1 to 5000 do
          begin
            TimeStamp := DateTimeToStr(Now);
            // 5% chance of an error
            if Random(100) < 5 then
              Line := Format(SERVER_ERROR, [TimeStamp])
            else
              Line := Format(OPERATION_INFO, [TimeStamp, j]);

            LogFile.Add(Line);
          end;
          LogFile.SaveToFile(TPath.Combine(LogsDirectory, Format('app_log_%d.txt', [i])));
        end;
        LogWrite('Log files generated successfully!');
      finally
        LogFile.Free;
        FCurrentTask := nil;
        SetButtonStates(IsStopped);
      end;
    end);
end;

procedure TMainForm.ProcessFilesButtonClick(Sender: TObject);
begin
  if Assigned(FLogProcessor) then
    Exit;
  LogMemo.Lines.Clear;
  LogWrite('> Starting parallel processing of log files...');
  SetButtonStates(IsRunning);
  ProgressBar.Position := 0;
  FLogProcessor := TLogFileProcessor.Create;
  FLogProcessor.ProcessLogsAsync(FLogsDirectory, LogProgress, LogCompletion);
end;

procedure TMainForm.CancelButtonClick(Sender: TObject);
begin
  if Assigned(FCurrentTask) then
    FCurrentTask.Cancel;
  if Assigned(FLogProcessor) then
    FLogProcessor.Cancel;
end;

procedure TMainForm.LogCompletion(const WasCancelled: Boolean; const TotalFiles, TotalLines,
  TotalWords: Int64; const ErrorLines: TStrings);
begin
  try
    if csDestroying in ComponentState then
      Exit;

    if WasCancelled then
      LogWrite('--- PROCESSING CANCELED ---')
    else
    begin
      LogWrite('--- FINAL REPORT ---');
      LogWrite(Format('Total Files Processed: %d', [TotalFiles]));
      LogWrite(Format('Total Lines Analyzed: %d', [TotalLines]));
      LogWrite(Format('Total Words Counted: %d', [TotalWords]));
      LogWrite(Format('Total Errors Found: %d', [ErrorLines.Count]));
      if ErrorLines.Count > 0 then
      begin
        LogWrite('');
        LogWrite('--- ERROR LINES ---');
        LogMemo.Lines.AddStrings(ErrorLines);
      end;
      LogWrite('--------------------');
    end;
  finally
    if Assigned(FLogProcessor) then
    begin
      FLogProcessor.Free;
      FLogProcessor := nil;
    end;
    SetButtonStates(IsStopped);
  end;
end;

procedure TMainForm.LogProgress(const ProcessedCount, TotalCount: Integer; const FileName: string);
begin
  if (csDestroying in ComponentState) or (FLogProcessor = nil) then
    Exit;
  ProgressBar.Max := TotalCount;
  ProgressBar.Position := ProcessedCount;
end;

procedure TMainForm.SetButtonStates(RunningState: TRunningState);
begin
  TThread.ForceQueue(nil,
    procedure
    begin
      GenerateLogFilesButton.Enabled := RunningState = IsStopped;
      ProcessFilesButton.Enabled := RunningState = IsStopped;
      CancelButton.Enabled := RunningState = IsRunning;
    end);
end;

end.
