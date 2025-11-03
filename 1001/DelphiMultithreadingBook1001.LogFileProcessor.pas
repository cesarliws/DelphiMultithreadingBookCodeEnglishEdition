unit DelphiMultithreadingBook1001.LogFileProcessor;

interface

uses
  System.Classes, System.Threading;

type
  TOnLogProgress = reference to procedure(const ProcessedCount, TotalCount: Integer;
    const FileName: string);

  TOnLogCompletion = reference to procedure(const WasCancelled: Boolean; const TotalFiles,
    TotalLines, TotalWords: Int64; const ErrorLines: TStrings);

  TLogFileProcessor = class
  private
    FProcessorTask: ITask;
  public
    procedure ProcessLogsAsync(const DirectoryPath: string; OnProgress: TOnLogProgress;
      OnComplete: TOnLogCompletion);
    procedure Cancel;
  end;

implementation

uses
  System.Diagnostics, System.IOUtils, System.SyncObjs, System.SysUtils, System.Types;

{ TLogFileProcessor }

procedure TLogFileProcessor.Cancel;
begin
  if Assigned(FProcessorTask) then
    FProcessorTask.Cancel;
end;

procedure TLogFileProcessor.ProcessLogsAsync(const DirectoryPath: string; OnProgress:
  TOnLogProgress; OnComplete: TOnLogCompletion);
begin
  FProcessorTask := TTask.Run(
    procedure
    var
      ErrorLines: TStringList;
      ErrorLock: TCriticalSection;
      Files: TStringDynArray;
      LoopResult: TParallel.TLoopResult;
      ProcessedCount: Integer;
      TotalLines, TotalWords: Int64;
    begin
      ErrorLines := nil;
      ErrorLock := nil;
      try
        TotalLines := 0;
        TotalWords := 0;
        ProcessedCount := 0;
        ErrorLines := TStringList.Create;
        ErrorLock := TCriticalSection.Create;

        Files := TDirectory.GetFiles(DirectoryPath, '*.txt');
        if Length(Files) = 0 then
        begin
          TThread.Queue(nil, procedure
            begin
              if Assigned(OnComplete) then
                OnComplete(False, 0, 0, 0, ErrorLines);
            end);
          // The finally block below will handle cleanup
          Exit;
        end;

        LoopResult := TParallel.For(Low(Files), High(Files),
          procedure(i: Integer; LoopState: TParallel.TLoopState)
          var
            FileContent, Line: string;
            LineCount, WordCount: Integer;
            LocalErrorLines: TStringList;
          begin
            if Self.FProcessorTask.Status = TTaskStatus.Canceled then
            begin
              LoopState.Stop;
              Exit;
            end;

            FileContent := TFile.ReadAllText(Files[i]);
            LineCount := 0;
            WordCount := 0;
            LocalErrorLines := TStringList.Create;
            try
              for Line in FileContent.Split([sLineBreak]) do
              begin
                Inc(LineCount);
                WordCount := WordCount + Length(Line.Split([' ']));
                if Line.Contains('ERROR') then
                  LocalErrorLines.Add(Format('[%s] %s', [TPath.GetFileName(Files[i]), Line]));
              end;

              TInterlocked.Add(TotalLines, LineCount);
              TInterlocked.Add(TotalWords, WordCount);
              if LocalErrorLines.Count > 0 then
              begin
                ErrorLock.Enter;
                try
                  ErrorLines.AddStrings(LocalErrorLines);
                finally
                  ErrorLock.Leave;
                end;
              end;

              TInterlocked.Increment(ProcessedCount);
              TThread.Queue(nil, procedure
                begin
                  if Assigned(OnProgress) then
                    OnProgress(ProcessedCount, Length(Files), TPath.GetFileName(Files[i]));
                end);
            finally
              LocalErrorLines.Free;
            end;
          end);

        // -- Completion Block --
        TThread.Queue(nil, procedure
          begin
            try
              // Call the completion event, passing the results
              if Assigned(OnComplete) then
                OnComplete(FProcessorTask.Status = TTaskStatus.Canceled, Length(Files),
                  TotalLines, TotalWords, ErrorLines);
            finally
              // Ensure objects are freed AFTER the event is called
              ErrorLines.Free;
              ErrorLock.Free;
            end;
          end);

      except
        // In case of an exception (e.g., TDirectory.GetFiles fails)
        on E: Exception do
        begin
          TThread.Queue(nil, procedure
            begin
              try
                // Ensure ErrorLines is not nil, if the exception occurred before its creation
                if not Assigned(ErrorLines) then
                  ErrorLines := TStringList.Create;

                ErrorLines.Insert(0, Format('CRITICAL ERROR IN TASK: %s', [E.Message]));

                if Assigned(OnComplete) then
                  OnComplete(True, 0, 0, 0, ErrorLines); // Signal failure
              finally
                // Ensure cleanup even in case of an exception
                if Assigned(ErrorLines) then ErrorLines.Free;
                if Assigned(ErrorLock) then ErrorLock.Free;
              end;
            end);
        end;
      end;
    end);
end;

end.
