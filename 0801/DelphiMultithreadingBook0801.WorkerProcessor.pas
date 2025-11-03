unit DelphiMultithreadingBook0801.WorkerProcessor;

interface

uses
  System.Classes, System.SysUtils;

type
  // Define the type of callback that the WorkerProcessor will use to report  progress and errors
  TProgressUpdateCallback = reference to procedure(const Text: string; Progress: Integer);
  TErrorCallback = reference to procedure(const Text: string);

  TWorkerProcessor = class
  private
    FCancelRequested: Boolean;
    // Callbacks that will be invoked by the Processor
    FUpdateCallback: TProgressUpdateCallback;
    FErrorCallback: TErrorCallback;
  public
    // Constructor now receives the progress callback and the error callback
    constructor Create(UpdateCallback: TProgressUpdateCallback;
      ErrorCallback: TErrorCallback = nil);
    procedure PerformLongCalculation;
    procedure RequestCancel;
    // Method to report errors (called by the thread if something goes wrong)
    procedure ReportErrorFmt(const ErrorText: string; const Args: array of const);
    property CancelRequested: Boolean read FCancelRequested;
  end;

const
  CancelProcessingText = 'Calculation Canceled (Processor).';

implementation

uses
  DelphiMultithreadingBook.Utils;

{ TWorkerProcessor }

constructor TWorkerProcessor.Create(UpdateCallback: TProgressUpdateCallback;
  ErrorCallback: TErrorCallback);
begin
  inherited Create;
  FCancelRequested := False;
  FUpdateCallback := UpdateCallback;
  FErrorCallback := ErrorCallback;
end;

procedure TWorkerProcessor.PerformLongCalculation;
var
  i: Integer;
begin
  DebugLogWrite('TWorkerProcessor: Starting calculation...');
  try
    for i := 1 to 10 do
    begin
      if FCancelRequested then
      begin
        DebugLogWrite('TWorkerProcessor: Calculation CANCELED.');
        // Notifies the progress callback about the cancellation
        if Assigned(FUpdateCallback) then
          TThread.Queue(nil,
            procedure
            begin
              FUpdateCallback(CancelProcessingText, 0);
            end);
        Exit;
      end;

      DebugLogWrite('TWorkerProcessor: Step %d...', [i]);
      // Simulates work
      Sleep(1000);
      // Notifies the progress callback
      if Assigned(FUpdateCallback) then
        TThread.Queue(nil,
          procedure
          begin
            FUpdateCallback(Format('Progress: %d', [i * 10]), i * 10);
          end);
    end;
    DebugLogWrite('TWorkerProcessor: Calculation completed.');
    // Notifies the progress callback about the conclusion
    if Assigned(FUpdateCallback) then
      TThread.Queue(nil,
        procedure
        begin
          FUpdateCallback('Calculation Finalized (Processor).', 100);
        end);
  except
    on E: Exception do
    begin
      // Reports the error
      ReportErrorFmt('Error during calculation: %s', [E.Message]);
      DebugLogWrite('TWorkerProcessor: Unexpected exception in calculation: %s', [E.Message]);
      // Re-raises the exception so the TWorkerThread can catch it if desired
      raise;
    end;
  end;
end;

procedure TWorkerProcessor.RequestCancel;
begin
  FCancelRequested := True;
end;

procedure TWorkerProcessor.ReportErrorFmt(const ErrorText: string; const Args: array of const);
var
  Error: string;
begin
  Error := Format(ErrorText, Args);
  // Reports the error
  if Assigned(FErrorCallback) then
    TThread.Queue(nil,
      procedure
      begin
        FErrorCallback(Error);
      end);
end;

end.
